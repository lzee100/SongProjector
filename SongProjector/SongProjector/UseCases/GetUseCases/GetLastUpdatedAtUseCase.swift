//
//  GetLastUpdatedAtUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetLastUpdatedAtUseCase<T: Entity> {
    
    private let context = newMOCBackground
    
    func fetch() async -> Date? {
        await fetch(sort: .updatedAt(asc: false), fetchDeleted: true)
    }
    
    func fetch(predicates: [Predicate] = [], sort: SortDescriptor? = nil, predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and, fetchDeleted: Bool = false) async -> Date? {
        
        let request: NSFetchRequest<T> = GetCoreDataRequestUseCase.get(predicates: predicates, sort: sort, predicateCompoundPredicateType: predicateCompoundPredicateType, fetchDeleted: fetchDeleted)
        
        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                return result.first?.updatedAt?.date
            } catch {
                return nil
            }
        }
    }
}
