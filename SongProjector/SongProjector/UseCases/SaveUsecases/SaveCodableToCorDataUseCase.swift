//
//  SaveCodableToCorDataUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor SaveCodableToCorDataUseCase<T: FileTransferable> {
    
    enum SaveCodableToCorDataUseCaseError: LocalizedError {
        case unimplementedCase
        
        var errorDescription: String? {
            switch self {
            case .unimplementedCase: return "Could not save locally. Not implemented"
            }
        }
    }
    
    @discardableResult
    func save(entities: [T]) async throws -> [T] {
        
        if let codableEntities = entities as? ([ClusterCodable]) {
            try await SaveClustersUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([ThemeCodable]) {
            try await SaveThemeUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([TagCodable]) {
            try await SaveTagsUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([SongServiceSettingsCodable]) {
            try await SaveSongServiceSettingsUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([UserCodable]) {
            try await SaveUsersUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([ChurchCodable]) {
            try await SaveChurchUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([AdminCodable]) {
            try await SaveAdminUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([ContractCodable]) {
            try await SaveContractCodable().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([SongServicePlayDateCodable]) {
            try await SaveSongServicePlayDateUseCase().save(entities: codableEntities)
            return entities
        }
        if let codableEntities = entities as? ([UniversalUpdatedAtCodable]) {
            try await SaveUniversalUpdatedAtUseCase().save(entities: codableEntities)
            return entities
        }
        throw SaveCodableToCorDataUseCaseError.unimplementedCase
    }
}
