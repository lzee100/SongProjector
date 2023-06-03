//
//  GetNewTagPositionUseCase.swift
//  
//
//  Created by Leo van der Zee on 29/05/2023.
//

import Foundation
import CoreData

actor GetNewTagPositionUseCase {
    
    func get() async throws -> Int {
        let context = newMOCBackground
        let request: NSFetchRequest<Tag> = GetCoreDataRequestUseCase.get(sort: .position(asc: false), fetchDeleted: true)
        
        return try await context.perform {
            let result = try context.fetch(request)
            if let position = result.first?.position {
                return position.intValue + 1
            }
            return 0
        }
    }
}
