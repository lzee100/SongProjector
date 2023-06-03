//
//  VChurch.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VChurch: VEntity {
        
    // MARK: - Encodable
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    
    
    // MARK: - Decodable
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        try super.initialization(decoder: decoder)
    }
    
    override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
        super.setPropertiesTo(entity: entity, context: context)
    }
    
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
    }
    
    convenience init(church: Church, context: NSManagedObjectContext) {
        self.init()
        getPropertiesFrom(entity: church, context: context)
    }
    
}
