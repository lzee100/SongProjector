//
//  DeleteAllEntitiesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor DeleteAllEntitiesUseCase {
    
    private let context = newMOCBackground
    
    func deleteAll() async {
        Store.reset()
    }
}

