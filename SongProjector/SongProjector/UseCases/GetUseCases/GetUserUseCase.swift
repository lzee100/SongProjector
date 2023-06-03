//
//  GetUserUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetUserUseCase {
    
    private let context = newMOCBackground
    
    func get() async -> UserCodable? {
        let request: NSFetchRequest<User> = GetCoreDataRequestUseCase.get()
        
        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                if let user = result.last {
                    return UserCodable(entity: user)
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
    }
}
