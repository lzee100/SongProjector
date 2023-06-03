//
//  SaveSongServicePlayDateUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveSongServicePlayDateUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [SongServicePlayDateCodable]) async throws {
                
        try await context.perform {
            try entities.forEach { songServicePlayDate in
                try self.get(songServicePlayDate)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    private func get(_ songServicePlayDate: SongServicePlayDateCodable) throws -> NSManagedObject {
        
        let songServicePlayDates: [SongServicePlayDate] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: songServicePlayDate.id)], fetchDeleted: true)
        
        if let entity = songServicePlayDates.first {
            try setProperties(from: songServicePlayDate, to: entity)
            return entity
        } else {
            let entity: SongServicePlayDate = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: songServicePlayDate, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: SongServicePlayDateCodable, to entity: SongServicePlayDate) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
        entity.playDate = codable.playDate
        entity.appInstallId = codable.appInstallId
    }
}

