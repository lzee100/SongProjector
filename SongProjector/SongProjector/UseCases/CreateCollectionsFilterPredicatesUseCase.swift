//
//  CreateCollectionsFilterPredicatesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FilteredCollectionsUseCase {
    
    static func getCollectionsIn(collections: [ClusterCodable], searchText: String?, selectedTagIds: [String], showDeleted: Bool) async -> [ClusterCodable] {

        return collections.filter { collection in
            
            func isDeleted(collection: ClusterCodable) -> Bool {
                if uploadSecret != nil {
                    return collection.rootDeleteDate != nil
                }
                return collection.deleteDate != nil
            }
            
            func containsTagId(collection: ClusterCodable) -> Bool {
                guard selectedTagIds.count > 0 else {
                    return true
                }
                return collection.tagIds.map { id in selectedTagIds.contains(id) }.filter { $0 }.count > 0
            }
            if let searchText {
                if collection.title?.localizedCaseInsensitiveContains(searchText) ?? false {
                    return containsTagId(collection: collection) && (showDeleted ? isDeleted(collection: collection) : !isDeleted(collection: collection))
                }
                return false
            } else {
                func isDeleted(collection: ClusterCodable) -> Bool {
                    return collection.deleteDate != nil || collection.rootDeleteDate != nil
                }
                return containsTagId(collection: collection) && (showDeleted ? isDeleted(collection: collection) : !isDeleted(collection: collection))
            }
        }.sorted(by: { $0.title ?? "" < $1.title ?? "" })
    }
    
    static func getCollections(searchText: String?, showDeleted: Bool, selectedTagIds: [String]) async -> [ClusterCodable] {

        let predicates = predicatesFor(searchText: searchText, showDeleted: showDeleted, selectedTagIds: selectedTagIds)

        return await GetClustersUseCase().fetch(predicates: predicates, fetchDeleted: showDeleted)
    }
    
    private static func predicatesFor(searchText: String?, showDeleted: Bool, selectedTagIds: [String]) -> [Predicate] {
        let searchText = (searchText ?? "").lowercased()
        var predicates: [Predicate] = []
//        filterOutClustersWithInstrumentsBasedOnContract(&predicates)
        filter(selectedTagIds: selectedTagIds, predicates: &predicates)
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
    
    private static func filter(selectedTagIds: [String], predicates: inout [Predicate]) {
        if selectedTagIds.count > 0 {
            let tagIdsPredicates: [Predicate] = selectedTagIds.map { .customWithValue(format:"tagIds CONTAINS %@", value: $0) }
            predicates.append(.compound(predicates: tagIdsPredicates, isOr: true))
        }
    }
    
    private static func filter(searchText: String, predicates: inout [Predicate]) {
        if searchText != "" {
            predicates.append(.customWithValue(format: "title contains[c] %@", value: searchText))
        }
    }
    
}
