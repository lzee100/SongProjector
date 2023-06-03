//
//  SaveAdminUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveAdminUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [AdminCodable]) async throws {
                
        try await context.perform {
            try entities.forEach { admin in
                try self.get(admin)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    private func get(_ admin: AdminCodable) throws -> NSManagedObject {
        
        let admins: [Admin] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: admin.id)], fetchDeleted: true)
        
        if let entity = admins.first {
            try setProperties(from: admin, to: entity)
            return entity
        } else {
            let entity: Admin = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: admin, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: AdminCodable, to entity: Admin) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
    }
}
