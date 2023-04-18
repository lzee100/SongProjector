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
        let results = try await submitFiles()
        
        if let failedResult = results.first(where: { $0.isFailed }) {
            return failedResult
        } else {
            return .success
        }
    }
    
    private func submitFiles() async throws -> [TransferResult] {
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

struct SubmitEntitiesUseCase<T: FileTransferable> {
    
    enum EndPoint: String {
        case themes = "themes"
    }
    
    enum ProgressResult: Equatable {
        case idle
        case preSubmit
        case submit
        case saveLocally
        case finished(Result<[FileTransferable], Error>)
        
        var progress: CGFloat {
            switch self {
            case .idle: return 0
            case .preSubmit: return 0.2
            case .submit: return 0.6
            case .saveLocally: return 0.8
            case .finished: return 1
            }
        }
        
        static func == (lhs: SubmitEntitiesUseCase<T>.ProgressResult, rhs: SubmitEntitiesUseCase<T>.ProgressResult) -> Bool {
            return lhs.progress == rhs.progress
        }
    }
    
    private let endpoint: String
    private let requestMethod: RequestMethod
    private let uploadObjects: [FileTransferable]
    private let managedObjectContextHandler = ManagedObjectContextHandler<T>()
    private let filesTransferUseCase: FilesTransferUseCase
    @Binding var result: ProgressResult
    
    init(endpoint: EndPoint, requestMethod: RequestMethod, uploadObjects: [FileTransferable], result: Binding<ProgressResult>) {
        self.endpoint = endpoint.rawValue
        self.requestMethod = requestMethod
        self.uploadObjects = uploadObjects
        self.filesTransferUseCase = FilesTransferUseCase(transferObjects: uploadObjects.flatMap { $0.transferObjects })
        self._result = result
    }
    
    func submit() {
        Task {
            do {
                result = .preSubmit
                let deleteFiles = getDeleteDeletedFiles()
                let uploadOrDownloadFilesResult = try await uploadOrDownloadFiles()
                switch uploadOrDownloadFilesResult {
                case .failed(error: let error):
                    result = .finished(.failure(error))
                case .success:
                    let transferObjects = uploadObjects.flatMap { $0.uploadObjects }
                    var updatedUploadObjects: [FileTransferable] = []
                    for uploadObject in uploadObjects {
                        var updatedUploadObject = uploadObject
                        updatedUploadObject.clearDataForDeletedObjects(forceDelete: requestMethod == .delete)
                        try updatedUploadObject.setTransferObjects(transferObjects)
                        setDeleteDateIfneeded(&updatedUploadObject)
                        updatedUploadObjects.append(updatedUploadObject)
                    }
                    let workload = updatedUploadObjects.map { SubmitCodableUseCase(endpoint: endpoint, requestMethod: requestMethod, uploadObject: $0) }
                    result = .submit
                    let submittedEntities = try await submit(useCases: workload)
                    result = .saveLocally
                    managedObjectContextHandler.save(entities: submittedEntities) { result in
                        switch result {
                        case .success(let uploadObjects):
                            deleteFiles.forEach({ $0.delete(completion: nil) })
                            self.result = .finished(.success(uploadObjects))
                        case .failure(let error): self.result = .finished(.failure(error))
                        }
                    }
                }
            } catch {
                result = .finished(.failure(error))
            }
        }
    }
    
    private func uploadOrDownloadFiles() async throws -> TransferResult {
        try await filesTransferUseCase.start()
    }
    
    private func submit(useCases: [SubmitCodableUseCase]) async throws -> [FileTransferable] {
        return try await withThrowingTaskGroup(of: FileTransferable.self, body: { group in
            for useCase in useCases {
                group.addTask {
                    let result = try await useCase.submit()
                    switch result {
                    case .success(let success):
                        return success
                    case .failure(let failure):
                        throw failure
                    }
                }
            }
            
            var results: [FileTransferable] = []
            for try await (result) in group {
                results.append(result)
            }
            return results
        })
    }
    
    private func getDeleteDeletedFiles() -> [StorageReference] {
        var deletableFiles: [StorageReference] = []
        
        uploadObjects.forEach { uploadObject in
            uploadObject.getDeleteObjects(forceDelete: self.requestMethod == .delete).forEach({ awsPath in
                deletableFiles.append(Storage.storage().reference().child("images").child(awsPath))
            })
        }
        return deletableFiles
    }
    
    private func setDeleteDateIfneeded(_ uploadObject: inout FileTransferable) {
        if requestMethod == .delete {
            uploadObject.deleteDate = Date()
            if uploadSecret != nil {
                uploadObject.rootDeleteDate = Date()
            }
        }
    }
}

struct SubmitCodableUseCase {
    private let endpoint: String
    private let requestMethod: RequestMethod
    private let uploadObject: FileTransferable
    private let db = Firestore.firestore()
    private(set) var result: Result<FileTransferable, Error>?
    
    init(endpoint: String, requestMethod: RequestMethod, uploadObject: FileTransferable) {
        self.endpoint = endpoint
        self.requestMethod = requestMethod
        self.uploadObject = uploadObject
    }
    
    func submit() async throws -> Result<FileTransferable, Error> {
        var uploadObject = try uploadObject.setUpdatedAt().setUserUID()
        if case .delete = requestMethod {
            uploadObject = uploadObject.setDeleteDate()
        }
        let data = try JSONEncoder().encode(uploadObject)
        guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return .failure(CodableError.encoding)
        }
        try await self.db.collection(endpoint).document(uploadObject.id).setData(json)
        uploadObject.id = self.db.collection(endpoint).document(uploadObject.id).documentID
        return .success(uploadObject)
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
