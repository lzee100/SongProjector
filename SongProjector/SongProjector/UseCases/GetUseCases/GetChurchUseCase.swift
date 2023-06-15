//
//  GetChurchUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetChurchUseCase {
    
    private let context = newMOCBackground
    
    func get() async -> ChurchCodable? {
        let request: NSFetchRequest<Church> = GetCoreDataRequestUseCase.get()
        
        return await context.perform {
            do {
                let result = try self.context.fetch(request)
                if let church = result.last {
                    return ChurchCodable(entity: church)
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
    }
}
