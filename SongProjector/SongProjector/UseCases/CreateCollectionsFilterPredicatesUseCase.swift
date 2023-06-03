//
//  CreateCollectionsFilterPredicatesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FilteredCollectionsUseCase {
    
    static func getCollections(searchText: String?, showDeleted: Bool, selectedTags: [TagCodable]) async -> [ClusterCodable] {
        let predicates = predicatesFor(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
        
        return await GetClustersUseCase().fetch(predicates: predicates, fetchDeleted: showDeleted)
    }
    
    private static func predicatesFor(searchText: String?, showDeleted: Bool, selectedTags: [TagCodable]) -> [Predicate] {
        let searchText = (searchText ?? "").lowercased()
        var predicates: [Predicate] = []
//        filterOutClustersWithInstrumentsBasedOnContract(&predicates)
        filter(selectedTags: selectedTags, predicates: &predicates)
        filter(searchText: searchText, predicates: &predicates)
        return predicates
    }
    
    private static func filterOutClustersWithInstrumentsBasedOnContract(_ predicates: inout [Predicate]) {
        if let user = VUser.first(moc: moc), !user.hasActiveSongContract {
            var songPreds: [Predicate] = []
            if !user.hasActiveSongContract {
                songPreds.append(.custom(format: "instrumentIds == nil"))
                songPreds.append(.customWithValue(format: "instrumentIds == %@", value: ""))
                let comp = Predicate.compound(predicates: songPreds, isOr: true)
                predicates.append(comp)
            }
        }
    }
    
    private static func filter(selectedTags: [TagCodable], predicates: inout [Predicate]) {
        if selectedTags.count > 0 {
            let tagIdsPredicates: [Predicate] = selectedTags.map { .customWithValue(format:"tagIds CONTAINS %@", value: $0.id) }
            predicates.append(.compound(predicates: tagIdsPredicates, isOr: true))
        }
    }
    
    private static func filter(searchText: String, predicates: inout [Predicate]) {
        if searchText != "" {
            predicates.append(.customWithValue(format: "title contains[c] %@", value: searchText))
        }
    }
    
}
