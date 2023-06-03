//
//  GetCoreDataRequestUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

struct GetCoreDataRequestUseCase {
    
    static func get<T: Entity>(predicates: [Predicate] = [], sort: SortDescriptor? = nil, predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and, fetchDeleted: Bool = false) -> NSFetchRequest<T> {
        var entityName: String {  return T.classForCoder().description().deletingPrefix("ChurchBeam.") }
        
        var predicates = predicates.map { $0.predicate }
        if !fetchDeleted {
            predicates.append(NSCompoundPredicate(andPredicateWithSubpredicates: predicates + [.skipDeleted, .skipRootDeleted]))
        }
        
        let request = NSFetchRequest<T>(entityName: entityName)
        //        request.returnsObjectsAsFaults = false
        request.shouldRefreshRefetchedObjects = true
        request.predicate = NSCompoundPredicate(type: predicateCompoundPredicateType, subpredicates: predicates)
        
        if let sortDiscriptor = sort {
            request.sortDescriptors = [sortDiscriptor.sortDescriptor]
        } else {
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        }
        return request
    }
}
