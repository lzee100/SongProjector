//
//  SaveUniversalUpdatedAtUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveUniversalUpdatedAtUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [UniversalUpdatedAtCodable]) async throws {
                
        try await context.perform {
            try entities.forEach { universalUpdatedAt in
                try self.get(universalUpdatedAt)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    private func get(_ universalUpdatedAt: UniversalUpdatedAtCodable) throws -> NSManagedObject {
        
        let universalUpdatedAts: [UniversalUpdatedAtEntity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: universalUpdatedAt.id)], fetchDeleted: true)
        
        if let entity = universalUpdatedAts.first {
            try setProperties(from: universalUpdatedAt, to: entity)
            return entity
        } else {
            let entity: UniversalUpdatedAtEntity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: universalUpdatedAt, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: UniversalUpdatedAtCodable, to entity: UniversalUpdatedAtEntity) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
        entity.universalUpdatedAt = codable.universalUpdatedAt?.nsDate
    }

}
