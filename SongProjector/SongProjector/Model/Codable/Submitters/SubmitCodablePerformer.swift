//
//  SubmitCodablePerformer.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import CoreData
import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import SwiftUI

struct FilesTransferUseCase {
    
    private let fileUploadUseCase: FileUploadsUseCase
    private let fileDownloadUseCase: FileDownloadUseCase
    private var transferUseCases: [TransferUseCaseProtocol] {
        return [fileUploadUseCase, fileDownloadUseCase]
    }
    var transferObjects: [TransferObject] {
        return fileUploadUseCase.results + fileUploadUseCase.results
    }
    
    init(transferObjects: [TransferObject]) {
        let uploadObjects = transferObjects.compactMap { $0 as? UploadObject }
        let downloadObjects = transferObjects.compactMap { $0 as? DownloadObject }
        fileDownloadUseCase = FileDownloadUseCase(downloadFiles: downloadObjects)
        fileUploadUseCase = FileUploadsUseCase(uploadFiles: uploadObjects)
    }
    
    func start() async throws -> TransferResult {
        let results = try await transferFiles()
        if let failedResult = results.first(where: { $0.isFailed }) {
            return failedResult
        } else {
            return .success
        }
    }
    
    private func transferFiles() async throws -> [TransferResult] {
        try await withThrowingTaskGroup(of: TransferResult.self) { group in
            for fetcher in transferUseCases {
                group.addTask {
                    let result = try await fetcher.start()
                    return result
                }
            }
            var results: [TransferResult] = []
            for try await (result) in group {
                results.append(result)
            }
            return results
        }
    }

}

struct FileDownloadUseCase: TransferUseCaseProtocol {
    
    private let fetchers: [FileFetcher]
    
    var results: [TransferObject] {
        return fetchers.map { $0.transferObject }
    }

    init(downloadFiles: [DownloadObject]) {
        fetchers = downloadFiles.map { FileFetcher(downloadObject: $0) }
    }
    
    func start() async throws -> TransferResult {
        let results = try await downloadFiles()
        
        if let failedResult = results.first(where: { $0.isFailed }) {
            return failedResult
        } else {
            return .success
        }
    }
    
    private func downloadFiles() async throws -> [TransferResult] {
        try await withThrowingTaskGroup(of: TransferResult.self) { group in
            for fetcher in fetchers {
                group.addTask {
                    let result = try await fetcher.startTransfer()
                    return result
                }
            }
            var results: [TransferResult] = []
            for try await (result) in group {
                results.append(result)
            }
            return results
        }
    }
}

protocol TransferUseCaseProtocol {
    var results: [TransferObject] { get }
    func start() async throws -> TransferResult
}
struct FileUploadsUseCase: TransferUseCaseProtocol {
    
    private let submitters: [FileSubmitter]
    
    var results: [TransferObject] {
        return submitters.map { $0.transferObject }
    }
    
    init(uploadFiles: [UploadObject]) {
        submitters = uploadFiles.map { FileSubmitter(transferObject: $0) }
    }
    
    func start() async throws -> TransferResult {
        let results = try await submitFiles()
        
        if let failedResult = results.first(where: { $0.isFailed }) {
            return failedResult
        } else {
            return .success
        }
    }
    
    private func submitFiles() async throws -> [TransferResult] {
        try await withThrowingTaskGroup(of: TransferResult.self) { group in
            for submitter in submitters {
                group.addTask {
                    let result = await submitter.startTransfer()
                    return result
                }
            }
            var results: [TransferResult] = []
            for try await (result) in group {
                results.append(result)
            }
            return results
        }
    }
}


struct ManagedObjectContextHandler<T: FileTransferable> {
    
    func save(entities: [FileTransferable], completion: ((Result<[FileTransferable], Error>) -> Void)) {
        let managedContext = newMOCBackground
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        do {
            try managedContext.performAndWait {
                entities.forEach { _ = $0.getManagedObjectFrom(managedContext) }
                try managedContext.save()
                try moc.save()
                return completion(.success(entities))
            }
        } catch {
            return completion(.failure(error))
        }
    }
}

enum RequesterResult: Equatable {
    case idle
    case preparation
    case transfer
    case saveLocally
    case finished(Result<[FileTransferable], Error>)
    
    var progress: CGFloat {
        switch self {
        case .idle: return 0
        case .preparation: return 0.2
        case .transfer: return 0.6
        case .saveLocally: return 0.8
        case .finished: return 1
        }
    }
    
    static func == (lhs: RequesterResult, rhs: RequesterResult) -> Bool {
        return lhs.progress == rhs.progress
    }
}

struct SubmitCodablePerformer<T: EntityCodableType> {
    
    private let requesterInfo: RequesterInfo
    private let body: [T]
    private let requestMethod: RequestMethod
    private let db = Firestore.firestore()

    init(body: [T], requestMethod: RequestMethod, requesterInfo: RequesterInfo) {
        self.body = body
        self.requestMethod = requestMethod
        self.requesterInfo = requesterInfo
    }
    
    func performSubmit(completion: @escaping ((Result<[T], Error>) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var workload = body
            var submittedDocuments: [T] = []
            
            func submitDocument(document: T) {
                
                do {
                    
                    var modifiedDocument = try updateDocumentDeleteDateUpdatedAtDate(document)
                    
                    let data = try JSONEncoder().encode(document)
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                        completion(.failure(CodableError.encoding))
                        return
                    }
                    
                    self.db.collection(self.requesterInfo.path).document(document.id).setData(json) { (error) in
                        if let error = error {
                            Queues.main.async {
                                completion(.failure(CodableError.submitting(error: error)))
                            }
                        } else {
                            modifiedDocument.id = self.db.collection(self.requesterInfo.path).document(document.id).documentID
                            submittedDocuments.append(modifiedDocument)
                            workload.removeFirst()
                            if let document = workload.first {
                                submitDocument(document: document)
                            } else {
                                do {
                                    try save(submittedDocuments) { savedDecodables in
                                        Queues.main.async {
                                            completion(.success(savedDecodables))
                                        }
                                    }
                                } catch {
                                    Queues.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        }
                    }
                    
                } catch {
                    Queues.main.async {
                        completion(.failure(CodableError.encodingJson(error: error)))
                    }
                    return
                }
            }
            if let document = workload.first {
                submitDocument(document: document)
            } else {
                completion(.success([]))
            }
        }
    }
    
    private func save(_ data: [T], completion: (([T]) -> Void)) throws {
        let managedContext = newMOCBackground
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        try managedContext.performAndWait {
            let managedObjects: [NSManagedObject] = data.map { $0.getManagedObjectFrom(managedContext) }
            try managedContext.save()
            try moc.save()
            completion(managedObjects.compactMap { T.init(managedObject: $0, context: managedContext) })
        }
    }
    
    private func updateDocumentDeleteDateUpdatedAtDate(_ document: T) throws -> T {
        var modifiedDocument = document
        if case .delete = self.requestMethod {
            if uploadSecret != nil {
                modifiedDocument.rootDeleteDate = Date()
            } else {
                modifiedDocument.deleteDate = Date()
            }
        }
        modifiedDocument.updatedAt = Date()

        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        modifiedDocument.userUID = userUID

        return modifiedDocument
    }
}
