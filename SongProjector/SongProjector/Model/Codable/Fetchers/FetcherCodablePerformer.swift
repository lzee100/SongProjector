//
//  FetcherCodablePerformer.swift
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

struct FetcherPerformer<T: EntityCodableType> {
    
    private let db = Firestore.firestore()
    private let fetchCount = 1
    let lastUpdatedAtKey = "updatedAt"
    let createdAtKey = "createdAt"
    let userIdKey = "userUID"
    let fetchAll: Bool
    
    init(fetchAll: Bool = true) {
        self.fetchAll = fetchAll
    }
    
    func fetch(fetcherInfo: RequesterInfo, snapshots: [QuerySnapshot] = [], completion: @escaping ((Result<[QuerySnapshot], Error>) -> Void)) {
        if let userId = Auth.auth().currentUser?.uid {
            var collection: Query = Firestore.firestore().collection(fetcherInfo.path)
            self.addFetchingParamsFor(userId: userId, fetcherInfo: fetcherInfo, collection: &collection)
            collection.getDocuments(source: .server) { (snapshot, error) in
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let snapshot = snapshot else {
                        completion(.success([]))
                        return
                    }
                    if snapshot.documents.count != 0 {
                        let decoded: [T] = (try? snapshot.decoded()) ?? []
                        fetcherInfo.setLastUpdatedAt(decoded)
                        if !fetchAll { // TODO: unmark
                            //                    fetch(object: object, snapshots: snapshots + [snapshot], completion: completion)
                        } else {
                            completion(.success(snapshots + [snapshot]))
                        }
                    } else {
                        completion(.success(snapshots))
                    }
                }
            }
        } else {
            completion(.failure(CodableError.noFireBaseUser))
        }
    }
    
    private func addFetchingParamsFor(userId: String, fetcherInfo: RequesterInfo, collection: inout Query) {
        if let lastUpdatedAt = fetcherInfo.lastUpdatedAt  {
            collection = self.db
                .collection(fetcherInfo.path)
                .whereField(self.userIdKey, isEqualTo: userId)
                .order(by: self.lastUpdatedAtKey, descending: false)
                .whereField(self.lastUpdatedAtKey, isGreaterThan: lastUpdatedAt)
                .limit(to: self.fetchCount)
        } else {
            collection = self.db
                .collection(fetcherInfo.path)
                .whereField(self.userIdKey, isEqualTo: userId)
                .order(by: self.lastUpdatedAtKey, descending: false)
                .limit(to: self.fetchCount)
        }
    }
}
