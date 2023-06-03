//
//  GetTagsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetTagsUseCase {
    
    private let context = newMOCBackground
    
    func fetch() async -> [TagCodable] {
        await fetch(predicates: [], sort: .position(asc: true), predicateCompoundPredicateType: .and, fetchDeleted: false)
    }
    
    func fetch(predicates: [Predicate] = [], sort: SortDescriptor? = nil, predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and, fetchDeleted: Bool = false) async -> [TagCodable] {

        let request: NSFetchRequest<Tag> = GetCoreDataRequestUseCase.get(predicates: predicates, sort: sort, predicateCompoundPredicateType: predicateCompoundPredicateType, fetchDeleted: fetchDeleted)
        
        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                return result.compactMap { TagCodable(entity: $0) }
            } catch {
                print("Failed")
                return []
            }
        }
    }
}
