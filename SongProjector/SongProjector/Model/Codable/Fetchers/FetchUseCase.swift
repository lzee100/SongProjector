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
    let lastUpdatedAtKey = "updatedAt"
    let createdAtKey = "createdAt"
    let userIdKey = "userUID"
    let fetchAll: Bool
    @Binding var result: RequesterResult

    init(endpoint: EndPoint, fetchAll: Bool = true, result: Binding<RequesterResult>) {
        self.endpoint = endpoint
        self.fetchAll = fetchAll
        self._result = result
    }
    
    func fetch(snapshots: [QuerySnapshot] = [], lastUpdatedAt: Date? = nil) {
        result = .transfer
        if let userId = Auth.auth().currentUser?.uid {
            var collection: Query = Firestore.firestore().collection(endpoint.rawValue)
            self.addFetchingParamsFor(userId: userId, lastUpdatedAt: lastUpdatedAt, collection: &collection)
            collection.getDocuments(source: .server) { (snapshot, error) in
                
                if let error = error {
                    result = .finished(.failure(error))
                } else {
                    guard let snapshot = snapshot else {
                        result = .finished(.success([]))
                        return
                    }
                    do {
                        if snapshot.documents.count != 0 {
                            let decoded: [T] = try snapshot.decoded()
                            let lastUpdatedAt = getLastUpdatedAt(currentLastUpdatedAt: lastUpdatedAt, objects: decoded)
                            if fetchAll {
                                fetch(snapshots: snapshots + [snapshot], lastUpdatedAt: lastUpdatedAt)
                            } else {
                                downloadFiles(try (snapshots + [snapshot]).decoded())
                            }
                        } else {
                            downloadFiles(try snapshots.decoded())
                        }
                    } catch {
                        result = .finished(.failure(error))
                    }
                }
            }
        } else {
            result = .finished(.failure(CodableError.noFireBaseUser))
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
    private func downloadFiles(_ entities: [T]) {
        Task {
            let fileDownloadUseCase = FileDownloadUseCase(downloadFiles: entities.flatMap { $0.downloadObjects as? [DownloadObject] ?? [] })
            let downloadResult = try await fileDownloadUseCase.start()
            
            switch downloadResult {
                
            case .failed(error: let error):
                
                result = .finished(.failure(error))
                
            case .success:
                
                var changedEntities: [T] = []
                for entity in entities {
                    var changeableEntity = entity
                    try changeableEntity.setTransferObjects(fileDownloadUseCase.results)
                    changedEntities.append(changeableEntity)
                }
                
                saveLocally(changedEntities)
                
            }
        }
    }
    
    private func saveLocally(_ entities: [T]) {
        result = .saveLocally
        
        managedObjectContextHandler.save(entities: entities) { result in
            switch result {
            case .success(let uploadObjects):
                self.result = .finished(.success(uploadObjects))
            case .failure(let error):
                self.result = .finished(.failure(error))
            }
        }
        
    }
}
