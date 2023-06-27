//
//  SaveThemeUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveThemeUseCase {
    
    func save(entities: [ThemeCodable]) async throws {
        
        let context = newMOCBackground
        
        try await context.perform {
            try entities.forEach { theme in
                try GetThemeEntityUseCase.get(theme, context: context)
            }
            try context.save()
        }
        try await context.parent?.perform {
            try context.parent?.save()
        }
        
    }
}
