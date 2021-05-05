//
//  VUniversalUpdatedAtEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VUniversalUpdatedAt: VEntity {
    
    var universalUpdatedAt: Date?


    enum CodingKeysUniversalUpdatedAtEntity: String, CodingKey {
        case universalUpdatedAt
    }
        
    
    
    // MARK: - Encodable
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysUniversalUpdatedAtEntity.self)
        if let upAt = universalUpdatedAt {
            try container.encode(upAt.intValue, forKey: .universalUpdatedAt)
        }
        try super.encode(to: encoder)
    }
    
    
    
    // MARK: - Decodable
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeysUniversalUpdatedAtEntity.self)
        if let universalUpdatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .universalUpdatedAt) {
            universalUpdatedAt = Date(timeIntervalSince1970: TimeInterval(universalUpdatedAtInt) / 1000)
        }
        try super.initialization(decoder: decoder)
    }
    
    override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
        super.setPropertiesTo(entity: entity, context: context)
        if let uniEntity = entity as? UniversalUpdatedAtEntity {
            uniEntity.universalUpdatedAt = universalUpdatedAt as NSDate?
        }

    }
    
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
        if let uniEntity = entity as? UniversalUpdatedAtEntity {
            universalUpdatedAt = uniEntity.universalUpdatedAt as Date?
        }
    }
    
    convenience init(universalUpdatedAt: UniversalUpdatedAtEntity, context: NSManagedObjectContext) {
        self.init()
        getPropertiesFrom(entity: universalUpdatedAt, context: context)
    }
    
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: UniversalUpdatedAtEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: UniversalUpdatedAtEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }
}
