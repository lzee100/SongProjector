//
//  FetchUseCaseAsync.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import CoreData
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import SwiftUI

enum FetUseCaseAsyncError: LocalizedError {
    case userNotLoggedIn
    
    var errorDescription: String {
        return "We don't have the right login credentials. Please login"
    }
}

struct FetchUseCaseAsync<T: FileTransferable, P: Entity> {

    private let endpoint: EndPoint
    private let db = Firestore.firestore()
    private let fetchCount = 5
    private let useCase: FetchUseCaseAsyncTask<T>
    private let lastUpdatedAtKey = "updatedAt"
    private let createdAtKey = "createdAt"
    private let userIdKey = "userUID"
    private let fetchAll: Bool
    
    init(endpoint: EndPoint, fetchAll: Bool = true) {
        self.endpoint = endpoint
        self.fetchAll = fetchAll
        useCase = FetchUseCaseAsyncTask<T>(endpoint: endpoint, fetchAll: fetchAll)
    }
    
    func fetch(snapshots: [QuerySnapshot] = []) async throws -> [T] {
        let lastUpdatedAt = await GetLastUpdatedAtUseCase<P>().fetch()
        return  try await useCase.fetch(lastUpdatedAt: lastUpdatedAt)
    }
}

enum DecodingError: LocalizedError {
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .decodingError(let error): return AppText.RequesterErrors.errorParsing(error)
        }
    }
}

actor FetchUseCaseAsyncTask<T: FileTransferable> {
        
    enum FetchUseCaseAsyncDownloadResult {
        case failed(LocalizedError)
        case succes([T])
    }
    
    private let endpoint: EndPoint
    private let db = Firestore.firestore()
    private let fetchCount = 5
    private let saveUseCase = SaveCodableToCorDataUseCase<T>()
    let lastUpdatedAtKey = "updatedAt"
    let createdAtKey = "createdAt"
    let userIdKey = "userUID"
    let fetchAll: Bool
    
    init(endpoint: EndPoint, fetchAll: Bool = true) {
        self.endpoint = endpoint
        self.fetchAll = fetchAll
    }
    
    func fetch(snapshots: [QuerySnapshot] = [], lastUpdatedAt: Date? = nil) async throws -> [T] {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FetUseCaseAsyncError.userNotLoggedIn
        }
        
        let collection = getCollection(userId: userId, lastUpdatedAt: lastUpdatedAt)
        let snapshot = try await collection.getDocuments(source: .server)
        
        do {
            if snapshot.count != 0 {
                let decoded: [T] = try snapshot.decoded()
                let lastUpdatedAt = self.getLastUpdatedAt(currentLastUpdatedAt: lastUpdatedAt, objects: decoded)
                if self.fetchAll {
                    return try await self.fetch(snapshots: snapshots + [snapshot], lastUpdatedAt: lastUpdatedAt)
                } else {
                    let entities = try await self.downloadFiles(try (snapshots + [snapshot]).decoded())
                    return try await self.save(entities)
                }
            } else if snapshots.count > 0 {
                let entities = try await self.downloadFiles(try snapshots.decoded())
                return try await self.save(entities)
            } else {
                return []
            }
        } catch {
            throw DecodingError.decodingError(error)
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
    
    func getCollection(userId: String, lastUpdatedAt: Date?) -> Query {
        var collection: Query = Firestore.firestore().collection(endpoint.rawValue)
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
        return collection
    }
    
    private func downloadFiles(_ entities: [T]) async throws -> [T] {
        guard entities.count > 0 else { return [] }
        do {
            let downloadedEntities = try await withThrowingTaskGroup(of: T.self) { group in
                for entity in entities {
                    group.addTask {
                        return try await FileDownloadUseCase().startDownloadingFor(entity)
                    }
                }
                
                var results: [T] = []
                for try await (result) in group {
                    results.append(result)
                }
                return results
                
            }
            return downloadedEntities
        } catch {
            return entities
        }
    }
    
    private func save(_ entities: [T]) async throws -> [T] {
        try await saveUseCase.save(entities: entities)
    }
}
