//
//  ManagedObjectContextHandlerUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor ManagedObjectContextHandler<T: FileTransferable> {
    
    @discardableResult
    func save(entities: [T]) async throws -> [T] {
        do {
            return try await withCheckedThrowingContinuation({ continuation in
                let managedContext = newMOCBackground
                managedContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                do {
                    try managedContext.performAndWait {
                        entities.forEach { _ = $0.getManagedObjectFrom(managedContext) }
                        try managedContext.save()
                        try moc.save()
                        continuation.resume(returning: entities)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
                
            })
        } catch {
            print(error)
            throw error
        }
    }
}

