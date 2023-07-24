//
//  GetSongServiceSettingsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetSongServiceSettingsUseCase {
    
    private let context = newMOCBackground
    
    func fetch(predicates: [Predicate] = [], predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and, fetchDeleted: Bool = false) async -> SongServiceSettingsCodable? {

        let request: NSFetchRequest<SongServiceSettings> = GetCoreDataRequestUseCase.get(predicates: predicates, predicateCompoundPredicateType: predicateCompoundPredicateType, fetchDeleted: fetchDeleted)
        
        return await context.perform {
            do {
                let all = try self.context.fetch(request)
                print(all)
                let result = try self.context.fetch(request).last
                
                let sections = try self.getSections(with: (result?.sectionIds ?? "").split(separator: ",").map(String.init))
                let sectionsCodable = try sections.map { section in
                    var sectionCodable = SongServiceSectionCodable(entity: section)
                    let tagIds = section.tagIds.split(separator: ",").map(String.init)
                    if tagIds.count > 0 {
                        let tags = try self.getTags(with: tagIds)
                        sectionCodable.tags = tags.compactMap { TagCodable(entity: $0) }
                    }
                    return sectionCodable
                }
                
                if let result {
                    var settingsCodable = SongServiceSettingsCodable(entity: result)
                    settingsCodable.sections = sectionsCodable
                    return settingsCodable
                } else {
                    return nil
                }
                
            } catch {
                print("Failed")
                return nil
            }
        }
    }
    
    private func getSections(with ids: [String]) throws -> [SongServiceSection] {
        
        guard ids.count > 0 else { return [] }
        
        let predicates: [Predicate] = ids.map { .get(id: $0) }
        
        let request: NSFetchRequest<SongServiceSection> = GetCoreDataRequestUseCase.get(
            predicates: predicates,
            sort: .position(asc: true),
            predicateCompoundPredicateType: .or,
            fetchDeleted: false
        )
        
        return try context.fetch(request)
        
    }
    
    private func getTags(with ids: [String]) throws -> [Tag] {
        
        guard ids.count > 0 else { return [] }
        
        let predicates: [Predicate] = ids.map { .get(id: $0) }
        
        let request: NSFetchRequest<Tag> = GetCoreDataRequestUseCase.get(
            predicates: predicates,
            sort: .position(asc: true),
            predicateCompoundPredicateType: .or,
            fetchDeleted: false
        )
        
        return try context.fetch(request)
    }

}
