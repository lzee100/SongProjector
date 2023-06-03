//
//  FetchPersistantEntitiesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

struct FetchPersistantEntitiesUseCase {
    
    static func fetchPersistend<T: Entity>(context: NSManagedObjectContext, predicates: [Predicate] = [], sort: SortDescriptor? = nil, predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and, fetchDeleted: Bool = false) throws -> [T] {
        
        let request: NSFetchRequest<T> = GetCoreDataRequestUseCase.get(predicates: predicates, sort: sort, predicateCompoundPredicateType: predicateCompoundPredicateType, fetchDeleted: fetchDeleted)
        
        return try context.fetch(request)
        
    }
    
}
