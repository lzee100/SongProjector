//
//  SubmitUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

struct SubmitUseCase<T: FileTransferable> {
    
    private let endpoint: String
    private let requestMethod: RequestMethod
    private let uploadObjects: [T]
    private let managedObjectContextHandler = ManagedObjectContextHandler<T>()
    private let deleteObjects: [DeleteObject]
    
    init(endpoint: EndPoint, requestMethod: RequestMethod, uploadObjects: [T], deleteObjects: [DeleteObject] = []) {
        self.endpoint = endpoint.rawValue
        self.requestMethod = requestMethod
        self.uploadObjects = uploadObjects
        self.deleteObjects = deleteObjects
    }
    
    @discardableResult
    func submit() async throws -> [T] {
        
        let deleteFiles = getDeleteDeletedFiles()
        let uploadFilesResult = try await uploadFiles()
        
        var updatedUploadObjects: [T] = []
        for uploadObject in uploadFilesResult {
            var updatedUploadObject: T = uploadObject
            updatedUploadObject.clearDataForDeletedObjects(forceDelete: requestMethod == .delete)
            setDeleteDateIfneeded(&updatedUploadObject)
            updatedUploadObjects.append(updatedUploadObject)
        }
        let workload = updatedUploadObjects.map { SubmitCodableSyncVersionUseCase<T>(endpoint: endpoint, requestMethod: requestMethod, uploadObject: $0) }
        let result = try await submit(useCases: workload)
        
        await deleteFilesOnAWS(files: deleteFiles)
        deleteFilesLocally()
        
        return try await managedObjectContextHandler.save(entities: result)
    }
    
    private func uploadFiles() async throws -> [T] {
        return try await withThrowingTaskGroup(of: T.self) { group in
            for uploadObject in uploadObjects {
                group.addTask {
                    try await FileUploadsUseCase().startUploadingFor(uploadObject)
                }
            }
            
            var results: [T] = []
            for try await (result) in group {
                results.append(result)
            }
            return results
            
        }
    }
    
    private func submit(useCases: [SubmitCodableSyncVersionUseCase<T>]) async throws -> [T] {
        return try await withThrowingTaskGroup(of: T.self, body: { group in
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
            
            var results: [T] = []
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
        self.deleteObjects.compactMap { $0.imagePathAWS }.forEach { awsPath in
            deletableFiles.append(Storage.storage().reference().child("images").child(awsPath))
        }
        return deletableFiles
    }
    
    private func deleteFilesOnAWS(files: [StorageReference]) async {
        await withTaskGroup(of: Void.self) { group in
            files.forEach { reference in
                group.addTask {
                    try? await reference.delete()
                }
            }
        }
    }
    
    private func deleteFilesLocally() {
        deleteObjects.flatMap { [$0.imagePath, $0.thumbnailPath].compactMap { $0 } }.forEach { name in
            try? FileManager.deleteFile(name: name)
        }
    }
    
    private func setDeleteDateIfneeded(_ uploadObject: inout T) {
        if requestMethod == .delete {
            uploadObject.deleteDate = Date()
            if uploadSecret != nil {
                uploadObject.rootDeleteDate = Date()
            }
        }
    }
}

struct SubmitCodableSyncVersionUseCase<T: FileTransferable> {
    private let endpoint: String
    private let requestMethod: RequestMethod
    private let uploadObject: T
    private let db = Firestore.firestore()
    private(set) var result: Result<T, Error>?
    
    init(endpoint: String, requestMethod: RequestMethod, uploadObject: T) {
        self.endpoint = endpoint
        self.requestMethod = requestMethod
        self.uploadObject = uploadObject
    }
    
    func submit() async throws -> Result<T, Error> {
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
        return .success(uploadObject as! T)
    }
}
