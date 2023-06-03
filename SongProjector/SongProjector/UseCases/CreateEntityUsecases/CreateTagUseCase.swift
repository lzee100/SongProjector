//
//  CreateTagUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor CreateTagUseCase {
    
    private let context = newMOCBackground
    
    func create(with title: String) async -> TagCodable? {
        await context.perform {
            let tag: Tag = CreatePersistentEntityUseCase.create(context: self.context)
            tag.title = title
            tag.createdAt = Date.localDate().nsDate
            return TagCodable(entity: tag)
        }
    }
    

}

