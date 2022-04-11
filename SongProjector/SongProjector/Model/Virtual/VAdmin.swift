//
//  VAdmin.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VAdmin: VEntity {
    
    let id: String
    let userUID: String
    let title: String?
    let createdAt: NSDate
    let updatedAt: NSDate?
    let deleteDate: NSDate?
    let rootDeleteDate: Date?
    
    enum CodingKeysAdmin: String, CodingKey {
        
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
       case userUID
    }
        
    
    
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
    
    convenience init(Admin: Admin, context: NSManagedObjectContext) {
        self.init()
        getPropertiesFrom(entity: Admin, context: context)
    }
    
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: Admin = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Admin = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }
}
