//
//  ResetCoreDataUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor ResetCoreDataUseCase {
        
    func reset() async throws {
        do {
            try DeleteAllFilesUseCase().delete()
            await DeleteAllEntitiesUseCase().deleteAll()
        } catch {
            await DeleteAllEntitiesUseCase().deleteAll()
            print(error)
            throw error
        }
    }
}
