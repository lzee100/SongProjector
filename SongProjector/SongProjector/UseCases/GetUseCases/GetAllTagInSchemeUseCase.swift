//
//  GetAllTagInSchemeUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetAllTagInSchemeUseCase {

    private let context = newMOCBackground

    func fetch() async -> [TagInSchemeCodable] {
        await fetch(predicates: [], sort: .position(asc: true), predicateCompoundPredicateType: .and, fetchDeleted: false)
    }

    func fetch(predicates: [Predicate] = [], sort: SortDescriptor? = nil, predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and, fetchDeleted: Bool = false) async -> [TagInSchemeCodable] {

        let request: NSFetchRequest<TagInScheme> = GetCoreDataRequestUseCase.get(predicates: predicates, sort: sort, predicateCompoundPredicateType: predicateCompoundPredicateType, fetchDeleted: fetchDeleted)

        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                return result.compactMap { TagInSchemeCodable(entity: $0) }
            } catch {
                print("Failed")
                return []
            }
        }
    }
}
