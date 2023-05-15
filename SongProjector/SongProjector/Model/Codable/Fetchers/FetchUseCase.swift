//
//  FetchUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import CoreData
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import SwiftUI

struct FetchUseCase<T: FileTransferable> {
    
    private let endpoint: EndPoint
    private let db = Firestore.firestore()
    private let fetchCount = 5
    private let managedObjectContextHandler = ManagedObjectContextHandler<T>()
    private let useCase: FetchUseCaseCallBack<T>
    let lastUpdatedAtKey = "updatedAt"
    let createdAtKey = "createdAt"
    let userIdKey = "userUID"
    let fetchAll: Bool
    @Binding var result: RequesterResult
    
    init(endpoint: EndPoint, fetchAll: Bool = true, result: Binding<RequesterResult>) {
        self.endpoint = endpoint
        self.fetchAll = fetchAll
        self._result = result
        useCase = FetchUseCaseCallBack<T>(endpoint: endpoint, fetchAll: fetchAll)
    }
    
    func fetch(snapshots: [QuerySnapshot] = [], lastUpdatedAt: Date? = nil) {
        useCase.fetch { progress in
            self.result = progress
        }
    }
}

class FetchUseCaseCallBack<T: FileTransferable> {
    
    private let endpoint: EndPoint
    private let db = Firestore.firestore()
    private let fetchCount = 5
    private let managedObjectContextHandler = ManagedObjectContextHandler<T>()
    let lastUpdatedAtKey = "updatedAt"
    let createdAtKey = "createdAt"
    let userIdKey = "userUID"
    let fetchAll: Bool
    
    init(endpoint: EndPoint, fetchAll: Bool = true) {
        self.endpoint = endpoint
        self.fetchAll = fetchAll
    }
    
    func fetch(snapshots: [QuerySnapshot] = [], lastUpdatedAt: Date? = nil, didProgress: @escaping ((RequesterResult) -> Void)) {
        didProgress(.preparation)
        if let userId = Auth.auth().currentUser?.uid {
            var collection: Query = Firestore.firestore().collection(endpoint.rawValue)
            self.addFetchingParamsFor(userId: userId, lastUpdatedAt: lastUpdatedAt, collection: &collection)
            collection.getDocuments(source: .server) { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    didProgress(.finished(.failure(error)))
                } else {
                    guard let snapshot = snapshot else {
                        didProgress(.finished(.success([])))
                        return
                    }
                    do {
                        if snapshot.documents.count != 0 {
                            let decoded: [T] = try snapshot.decoded()
                            let lastUpdatedAt = self.getLastUpdatedAt(currentLastUpdatedAt: lastUpdatedAt, objects: decoded)
                            if self.fetchAll {
                                self.fetch(snapshots: snapshots + [snapshot], lastUpdatedAt: lastUpdatedAt, didProgress: didProgress)
                            } else {
                                self.downloadFiles(try (snapshots + [snapshot]).decoded(), didProgress: didProgress)
                            }
                        } else {
                            self.downloadFiles(try snapshots.decoded(), didProgress: didProgress)
                        }
                    } catch {
                        didProgress(.finished(.failure(error)))
                    }
                }
            }
        } else {
            didProgress(.finished(.failure(CodableError.noFireBaseUser)))
        }
    }
    
    private func getLastUpdatedAt(currentLastUpdatedAt: Date?, objects: [EntityCodableType]) -> Date? {
        var lastUpdatedAt: Date? = nil
        objects.forEach { object in
            if let updatedAt = object.updatedAt {
                if let currentLastUpdatedAt = currentLastUpdatedAt, updatedAt.intValue > currentLastUpdatedAt.intValue {
                    lastUpdatedAt = (updatedAt as Date)
                } else {
                    lastUpdatedAt = updatedAt
                }
            }
        }
        return lastUpdatedAt
    }
    
    private func addFetchingParamsFor(userId: String, lastUpdatedAt: Date?, collection: inout Query) {
        if let lastUpdatedAt = lastUpdatedAt  {
            collection = self.db
                .collection(endpoint.rawValue)
                .whereField(self.userIdKey, isEqualTo: userId)
                .order(by: self.lastUpdatedAtKey, descending: false)
                .whereField(self.lastUpdatedAtKey, isGreaterThan: lastUpdatedAt.intValue)
                .limit(to: self.fetchCount)
        } else {
            collection = self.db
                .collection(endpoint.rawValue)
                .whereField(self.userIdKey, isEqualTo: userId)
                .order(by: self.lastUpdatedAtKey, descending: false)
                .limit(to: self.fetchCount)
        }
    }
//    20201117212400001860761F-0EDE-41FD-878B-FD8264A198DD.jpg
    private func downloadFiles(_ entities: [T], didProgress: @escaping ((RequesterResult) -> Void)) {
        Task {
            let fileDownloadUseCase = FileDownloadUseCase(downloadFiles: entities.flatMap { $0.downloadObjects as? [DownloadObject] ?? [] })
            let downloadResult = try await fileDownloadUseCase.start()
            
            switch downloadResult {
                
            case .failed(error: let error):
                
                didProgress(.finished(.failure(error)))
                
            case .success:
                
                var changedEntities: [T] = []
                for entity in entities {
                    var changeableEntity = entity
                    try changeableEntity.setTransferObjects(fileDownloadUseCase.results)
                    changedEntities.append(changeableEntity)
                }
                
                saveLocally(changedEntities, didProgress: didProgress)
                
            }
        }
    }
    
    private func saveLocally(_ entities: [T], didProgress: ((RequesterResult) -> Void)) {
        didProgress(.saveLocally)
        
        managedObjectContextHandler.save(entities: entities) { result in
            switch result {
            case .success(let uploadObjects):
                didProgress(.finished(.success(uploadObjects)))
            case .failure(let error):
                didProgress(.finished(.failure(error)))
            }
        }
        
    }
}
