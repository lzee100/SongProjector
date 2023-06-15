//
//  GetAdminUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetAdminUseCase {
    
    private let context = newMOCBackground
    
    func get() async -> AdminCodable? {
        let request: NSFetchRequest<Admin> = GetCoreDataRequestUseCase.get()
        
        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                if let admin = result.last {
                    return AdminCodable(entity: admin)
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
    }
}
