
////  GetTagEntitiesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

struct GetTagInSchemeUseCase {

    @discardableResult
    static func get(_ tag: TagInSchemeCodable, context: NSManagedObjectContext) throws -> NSManagedObject {

        let tags: [TagInScheme] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: tag.id)], fetchDeleted: true)

        if let entity = tags.first {
            try setProperties(fromTag: tag, to: entity)
            return entity
        } else {

            let entity: TagInScheme = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromTag: tag, to: entity)
            return entity
        }
    }

    private static func setProperties(fromTag tag: TagInSchemeCodable, to entity: TagInScheme) throws {
        entity.id = tag.id
        entity.userUID = tag.userUID
        entity.title = tag.title
        entity.createdAt = tag.createdAt.nsDate
        entity.updatedAt = tag.updatedAt?.nsDate
        entity.deleteDate = tag.deleteDate?.nsDate
        entity.rootDeleteDate = tag.rootDeleteDate?.nsDate

        if let positionInScheme = tag.positionInScheme {
            entity.positionInScheme = Int16(positionInScheme)
        }
        entity.isPinned = tag.isPinned
        entity.rootTagId = tag.rootTagId
    }

}
