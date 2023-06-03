//
//  CreatePersistentEntityUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

struct CreatePersistentEntityUseCase {
    
    static func create<T: Entity>(context: NSManagedObjectContext) -> T {
        let entityName: String = T.classForCoder().description().deletingPrefix("ChurchBeam.")
        let entityDes = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let entity = NSManagedObject(entity: entityDes!, insertInto: context) as! T
        entity.id = "ChurchBeam-\(UUID().uuidString)"
        return entity
    }

}
