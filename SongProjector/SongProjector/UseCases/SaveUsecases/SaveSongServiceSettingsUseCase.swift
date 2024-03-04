//
//  SaveSongServiceSettingsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveSongServiceSettingsUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [SongServiceSettingsCodable]) async throws {
                
        try await context.perform {
            try entities.forEach { songServiceSettings in
                try self.get(songServiceSettings)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    private func get(_ setting: SongServiceSettingsCodable) throws -> NSManagedObject {
        
        let settings: [SongServiceSettings] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: setting.id)], fetchDeleted: true)
        
        if let entity = settings.first {
            try setProperties(from: setting, to: entity)
            return entity
        } else {
            let entity: SongServiceSettings = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: setting, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: SongServiceSettingsCodable, to entity: SongServiceSettings) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
        
        entity.sectionIds = codable.sections.map { $0.id }.joined(separator: ",")
        
        try codable.sections.forEach { try get($0) }
    }
    
    @discardableResult
    private func get(_ section: SongServiceSectionCodable) throws -> NSManagedObject {
        
        let sections: [SongServiceSection] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: section.id)], fetchDeleted: true)
        
        if let entity = sections.first {
            try setProperties(from: section, to: entity)
            return entity
        } else {
            let entity: SongServiceSection = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: section, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: SongServiceSectionCodable, to entity: SongServiceSection) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
        
        entity.position = codable.position
        entity.numberOfSongs = codable.numberOfSongs
        entity.tagIds = codable.tags.compactMap({ $0.id }).joined(separator: ",")
        try codable.tags.forEach { try GetTagInSchemeUseCase.get($0, context: context) }
    }
}
