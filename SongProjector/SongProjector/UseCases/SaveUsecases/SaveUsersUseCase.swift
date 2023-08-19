//
//  SaveUsersUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveUsersUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [UserCodable]) async throws {
        
        try await context.perform {
            try entities.forEach { user in
                try self.get(user)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    private func get(_ user: UserCodable) throws -> NSManagedObject {
        
        let users: [User] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: user.id)], fetchDeleted: true)
        
        if let entity = users.first {
            try setProperties(from: user, to: entity)
            return entity
        } else {
            let entity: User = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: user, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: UserCodable, to entity: User) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
        entity.motherChurch = codable.motherChurch
    }
}
