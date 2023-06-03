//
//  SaveChurchUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveChurchUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [ChurchCodable]) async throws {
                
        try await context.perform {
            try entities.forEach { church in
                try self.get(church)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    private func get(_ church: ChurchCodable) throws -> NSManagedObject {
        
        let churches: [Church] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: church.id)], fetchDeleted: true)
        
        if let entity = churches.first {
            try setProperties(from: church, to: entity)
            return entity
        } else {
            let entity: Church = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: church, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: ChurchCodable, to entity: Church) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
    }

}

