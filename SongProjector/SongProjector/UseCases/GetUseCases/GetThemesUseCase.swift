//
//  GetThemesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetThemesUseCase {
    
    private let context = newMOCBackground
    
    func fetch() async -> [ThemeCodable] {
        await fetch(predicates: [.skipHidden], sort: .position(asc: true), predicateCompoundPredicateType: .and, fetchDeleted: false)
    }
    
    func fetch(predicates: [Predicate] = [], sort: SortDescriptor?, predicateCompoundPredicateType: NSCompoundPredicate.LogicalType = .and, fetchDeleted: Bool = false) async -> [ThemeCodable] {
        
        let request: NSFetchRequest<Theme> = GetCoreDataRequestUseCase.get(predicates: predicates, sort: sort, predicateCompoundPredicateType: predicateCompoundPredicateType, fetchDeleted: fetchDeleted)
        
        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                return result.compactMap { ThemeCodable(entity: $0) }
            } catch {
                print("Failed")
                return []
            }
        }
    }
}
