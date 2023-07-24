//
//  DeleteEntityByIdsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/07/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor DeleteEntityByIdsUseCase {
    
    private let ids: [String]
    private let context = newMOCBackground
    
    init(ids: [String]) {
        self.ids = ids
    }
    
    func delete() async throws {
        try await context.perform {
            let predicates = self.ids.map { Predicate.get(id: $0) }
            let request: NSFetchRequest<Entity> = GetCoreDataRequestUseCase.get(predicates: predicates, predicateCompoundPredicateType: NSCompoundPredicate.LogicalType.or, fetchDeleted: true)
            let result = try self.context.fetch(request)
            result.forEach { self.context.delete($0) }
            try self.context.save()
        }
        try await context.parent?.perform {
            try self.context.parent?.save()
        }

    }
}
