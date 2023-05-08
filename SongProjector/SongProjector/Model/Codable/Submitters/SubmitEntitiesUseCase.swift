//
//  SubmitEntitiesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import CoreData
import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import SwiftUI



struct SubmitEntitiesUseCase<T: FileTransferable> {
    
    
    private let endpoint: String
    private let requestMethod: RequestMethod
    private let uploadObjects: [FileTransferable]
    private let managedObjectContextHandler = ManagedObjectContextHandler<T>()
    private let filesTransferUseCase: FilesTransferUseCase
    @Binding var result: RequesterResult
    
    init(endpoint: EndPoint, requestMethod: RequestMethod, uploadObjects: [FileTransferable], result: Binding<RequesterResult>) {
        self.endpoint = endpoint.rawValue
        self.requestMethod = requestMethod
        self.uploadObjects = uploadObjects
        self.filesTransferUseCase = FilesTransferUseCase(transferObjects: uploadObjects.flatMap { $0.transferObjects })
        self._result = result
    }
    
    func submit() {
        Task {
            do {
                result = .preparation
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
                    result = .transfer
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
