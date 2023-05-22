//
//  CreateCollectionsFilterPredicatesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor FilteredCollectionsUseCase {
    
    func getCollections(searchText: String?, showDeleted: Bool, selectedTags: [TagCodable]) -> [ClusterCodable] {
        let predicates = predicatesFor(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
        let persitedClusters: [Cluster] = DataFetcher().getEntities(moc: moc, predicates: predicates, sort: NSSortDescriptor(key: "title", ascending: true), fetchDeleted: showDeleted)
        return persitedClusters.compactMap { ClusterCodable(managedObject: $0, context: moc) }
    }
    
    private func predicatesFor(searchText: String?, showDeleted: Bool, selectedTags: [TagCodable]) -> [NSPredicate] {
        let searchText = (searchText ?? "").lowercased()
        var predicates: [NSPredicate] = []
//        filterOutClustersWithInstrumentsBasedOnContract(&predicates)
        filter(showDeleted: showDeleted, predicates: &predicates)
        filter(selectedTags: selectedTags, predicates: &predicates)
        filter(searchText: searchText, predicates: &predicates)
        return predicates
    }
    
    private func filterOutClustersWithInstrumentsBasedOnContract(_ predicates: inout [NSPredicate]) {
        if let user = VUser.first(moc: moc), !user.hasActiveSongContract {
            var songPreds: [NSPredicate] = []
            if !user.hasActiveSongContract {
                songPreds.append(NSPredicate(format: "instrumentIds == nil"))
                songPreds.append(NSPredicate(format: "instrumentIds == %@", ""))
                let comp = NSCompoundPredicate(orPredicateWithSubpredicates: songPreds)
                predicates.append(and: [comp])
            }
        }
    }
    
    private func filter(showDeleted: Bool, predicates: inout [NSPredicate]) {
        if showDeleted {
            if uploadSecret != nil {
                predicates.append(format: "rootDeleteDate != nil")
            } else {
                predicates.append(format: "deleteDate != nil")
            }
        } else {
            predicates += [.skipDeleted, .skipRootDeleted]
        }
    }
    
    private func filter(selectedTags: [TagCodable], predicates: inout [NSPredicate]) {
        if selectedTags.count > 0 {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: selectedTags.map({ NSPredicate(format:"tagIds CONTAINS %@", $0.id) })))
        }
    }
    
    private func filter(searchText: String, predicates: inout [NSPredicate]) {
        if searchText != "" {
            predicates.append(NSPredicate(format: "title contains[c] %@", searchText))
        }
    }
    
}
