//
//  SaveTagsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveTagsUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [TagCodable]) async throws {
                
        try await context.perform {
            try entities.forEach { tag in
                try GetTagEntitiesUseCase.get(tag, context: self.context)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    

}
