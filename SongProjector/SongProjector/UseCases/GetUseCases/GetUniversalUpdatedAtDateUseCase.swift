//
//  GetUniversalUpdatedAtDateUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetUniversalUpdatedAtDateUseCase {
    
    private let context = newMOCBackground
    
    func get() async -> UniversalUpdatedAtCodable? {
        let request: NSFetchRequest<UniversalUpdatedAtEntity> = GetCoreDataRequestUseCase.get()
        
        return await context.perform {
            do {
                let entity = try self.context.fetch(request).last
                if let entity {
                    return UniversalUpdatedAtCodable(entity: entity)
                }
                return nil
            } catch {
                return nil
            }
        }
    }
}
