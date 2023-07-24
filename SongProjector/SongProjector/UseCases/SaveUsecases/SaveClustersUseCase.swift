//
//  SaveClustersUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData



actor SaveClustersUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [ClusterCodable]) async throws {
        
        try await context.perform {
            try entities.forEach { clusterCodable in
                _ = try self.getManagedObjectFrom(cluster: clusterCodable)
            }
            try self.context.save()
        }
        try await SaveSheetsUseCase().save(entities: entities.flatMap { $0.hasSheets })
        try await SaveInstrumentsUseCase().save(entities: entities.flatMap { $0.hasInstruments })
        
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    func getManagedObjectFrom(cluster: ClusterCodable) throws -> NSManagedObject? {
        
        let clusters: [Cluster] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: cluster.id)], fetchDeleted: true)
        
        if let entity = clusters.first {
            setProperties(from: cluster, to: entity)
            return entity
        } else {
            let entity: Cluster = CreatePersistentEntityUseCase.create(context: context)
            setProperties(from: cluster, to: entity)
            return entity
        }
    }
    
    private func setProperties(from clusterCodable: ClusterCodable, to entity: Cluster) {
        entity.id = clusterCodable.id
        entity.userUID = clusterCodable.userUID
        entity.title = clusterCodable.title
        entity.createdAt = clusterCodable.createdAt.nsDate
        entity.updatedAt = clusterCodable.updatedAt?.nsDate
        entity.deleteDate = clusterCodable.deleteDate?.nsDate
        entity.rootDeleteDate = clusterCodable.rootDeleteDate?.nsDate
        
        entity.sheetIds = clusterCodable.sheetIds.joined(separator: ",")
        entity.root = clusterCodable.root
        entity.isLoop = clusterCodable.isLoop
        entity.position = Int16(clusterCodable.position)
        entity.time = clusterCodable.time
        entity.themeId = clusterCodable.theme?.id ?? clusterCodable.themeId
        entity.church = clusterCodable.church
        entity.startTime = clusterCodable.startTime
        entity.lastShownAt = clusterCodable.lastShownAt as NSDate?
        entity.hasSheetPastors = clusterCodable.hasSheetPastors
        entity.instrumentIds = clusterCodable.hasInstruments.compactMap { $0.id }.joined(separator: ",")
        entity.sheetIds = clusterCodable.hasSheets.map { $0.id }.joined(separator: ",")
        entity.tagIds = clusterCodable.tagIds.joined(separator: ",")
        entity.showEmptySheetBibleText = clusterCodable.showEmptySheetBibleText
    }
    
}
