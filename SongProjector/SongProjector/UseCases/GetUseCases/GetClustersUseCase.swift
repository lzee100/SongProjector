//
//  GetClustersUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData


actor GetClustersUseCase {
    
    private let context = newMOCBackground
    
    func fetch(predicates: [Predicate] = []) async -> [ClusterCodable] {
        await fetch(predicates: [], sort: .title(asc: true), predicateCompoundPredicateType: .and, fetchDeleted: false)
    }
    
    func fetch(
        predicates: [Predicate] = [],
        sort: SortDescriptor? = .title(asc: true),
        predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and,
        fetchDeleted: Bool = false) async -> [ClusterCodable]
    {

        let request: NSFetchRequest<Cluster> = GetCoreDataRequestUseCase.get(predicates: predicates, sort: sort, predicateCompoundPredicateType: predicateCompoundPredicateType, fetchDeleted: fetchDeleted)
        
        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                
                let clusterWithAllInfo = try result.map {(
                    $0,
                    try self.getSheets(with: $0.sheetIds.split(separator: ",").map(String.init)),
                    try self.getTheme(with: $0.themeId),
                    try self.getInstruments(with: $0.instrumentIds?.split(separator: ",").map(String.init) ?? []),
                    try self.getTags(with: $0.tagIds.split(separator: (",")).map(String.init))
                )}
                
                let clusterCodables: [ClusterCodable] = clusterWithAllInfo.compactMap { info in
                    let (cluster, sheets, theme, instruments, tags) = info
                    var clusterCodable = ClusterCodable(managedObject: cluster)
                    var sheetCodables = sheets.getSheets()
                    
                    var themeCodable: ThemeCodable? {
                        if let theme {
                            return ThemeCodable(entity: theme)
                        }
                        return nil
                    }
                    let tagsCodable = tags.compactMap { TagCodable(entity: $0) }
                    let instrumentCodables = instruments.map { InstrumentCodable(entity: $0) }
                    clusterCodable?.theme = themeCodable
                    clusterCodable?.hasSheets = sheetCodables
                    clusterCodable?.hasInstruments = instrumentCodables.compactMap { $0 }
                    clusterCodable?.hasTags = tagsCodable
                    let listViewID = ([clusterCodable?.id] + (clusterCodable?.hasInstruments.map { $0.id } ?? [])).compactMap { $0 }.joined()
                    clusterCodable?.listViewID = listViewID
                    return clusterCodable
                }
                return clusterCodables

            } catch {
                print("Failed")
                return []
            }
        }
    }
    
    private func getSheets(with ids: [String]) throws -> [Sheet] {
        
        guard ids.count > 0 else { return [] }
        
        let predicates: [Predicate] = ids.map { .get(id: $0) }
        
        let request: NSFetchRequest<Sheet> = GetCoreDataRequestUseCase.get(
            predicates: predicates,
            sort: .position(asc: true),
            predicateCompoundPredicateType: .or,
            fetchDeleted: false
        )
        
        return try context.fetch(request)
    }
    
    private func getTheme(with id: String?) throws -> Theme? {
        
        guard let id = id else { return nil }
        
        let predicates: [Predicate] = [id].map { .get(id: $0) }
        
        let request: NSFetchRequest<Theme> = GetCoreDataRequestUseCase.get(
            predicates: predicates,
            predicateCompoundPredicateType: .or,
            fetchDeleted: false
        )
        
        return try context.fetch(request).first
        
    }
    
    private func getInstruments(with ids: [String]) throws -> [Instrument] {
        
        guard ids.count > 0 else { return [] }
        
        let predicates: [Predicate] = ids.map { .get(id: $0) }
        
        let request: NSFetchRequest<Instrument> = GetCoreDataRequestUseCase.get(
            predicates: predicates,
            predicateCompoundPredicateType: .or,
            fetchDeleted: false
        )
        
        return try context.fetch(request).sorted(by: { $0.type.position < $1.type.position })

    }
    
    private func getTags(with ids: [String]) throws -> [Tag] {
        
        guard ids.count > 0 else { return [] }
        
        let predicates: [Predicate] = ids.map { .get(id: $0) }
        
        let request: NSFetchRequest<Tag> = GetCoreDataRequestUseCase.get(
            predicates: predicates,
            predicateCompoundPredicateType: .or,
            fetchDeleted: false
        )
        
        return try context.fetch(request).sorted(by: { $0.position < $1.position })

    }

}
