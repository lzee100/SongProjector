//
//  GetNewThemePositionUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetNewThemePositionUseCase {
    
    func get() async throws -> Int {
        let context = newMOCBackground
        let request: NSFetchRequest<Theme> = GetCoreDataRequestUseCase.get(sort: .position(asc: false), fetchDeleted: true)
        
        return try await context.perform {
            let result = try context.fetch(request)
            if let position = result.first?.position {
                return position.intValue + 1
            }
            return 0
        }
    }
}
