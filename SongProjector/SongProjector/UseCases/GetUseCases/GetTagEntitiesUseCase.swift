//
//  GetTagEntitiesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

struct GetTagEntitiesUseCase {
    
    @discardableResult
    static func get(_ tag: TagCodable, context: NSManagedObjectContext) throws -> NSManagedObject {
        
        let tags: [Tag] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: tag.id)], fetchDeleted: true)
        
        if let entity = tags.first {
            try setProperties(fromTag: tag, to: entity)
            return entity
        } else {
                        
            let entity: Tag = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromTag: tag, to: entity)
            return entity
        }
    }

    private static func setProperties(fromTag tag: TagCodable, to entity: Tag) throws {
        entity.id = tag.id
        entity.userUID = tag.userUID
        entity.title = tag.title
        entity.createdAt = tag.createdAt.nsDate
        entity.updatedAt = tag.updatedAt?.nsDate
        entity.deleteDate = tag.deleteDate?.nsDate
        entity.rootDeleteDate = tag.rootDeleteDate?.nsDate
        
        entity.position = Int16(tag.position)
        entity.isDeletable = tag.isDeletable
    }

}
