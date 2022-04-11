//
//  VOrganization.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

struct VOrganization: VEntityType, Codable {
    
    let id: String
    let userUID: String
    let title: String?
    let createdAt: NSDate
    let updatedAt: NSDate?
    let deleteDate: NSDate?
    let rootDeleteDate: Date?
	
    var hasRoles: [VRole] = []
	var hasContractLedgers: [VContractLedger] = []
	
	enum CodingKeysOrganization:String,CodingKey
	{
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
		case hasRoles = "roles"
		case hasContractLedgers = "contractLedgers"
		case name
	}
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysOrganization.self)
        
        try container.encode(userUID, forKey: .userUID)
        try container.encode((createdAt as Date).intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
            //            let updatedAtString = GlobalDateFormatter.localToUTCNumber(date: updatedAt as Date)
            try container.encode((updatedAt as Date).intValue, forKey: .updatedAt)
        } else {
            try container.encode((createdAt as Date).intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
            //            let deleteDateString = GlobalDateFormatter.localToUTCNumber(date: deleteDate as Date)
            try container.encode((deleteDate as Date).intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
        
        try container.encode(eventDescription, forKey: .eventDescription)
        
        if let startDate = startDate {
            try container.encode((startDate as Date).intValue, forKey: .startDate)
        }
        if let endDate = endDate {
            try container.encode((endDate as Date).intValue, forKey: .endDate)
        }
        
		try container.encode(hasRoles, forKey: .hasRoles)
		try container.encode(hasContractLedgers, forKey: .hasContractLedgers)
		try super.encode(to: encoder)
		try container.encode(title, forKey: .name)
	}
	
	
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysOrganization.self)
		self.hasRoles = try (container.decodeIfPresent([VRole].self, forKey: .hasRoles) ?? [])
		self.hasContractLedgers = try container.decodeIfPresent([VContractLedger].self, forKey: .hasContractLedgers) ?? []
		self.title = try container.decodeIfPresent(String.self, forKey: .name)
        
        id = try container.decode(String.self, forKey: .id)
        userUID = try container.decode(String.self, forKey: .userUID)
        let createdAtInt = try container.decode(Int64.self, forKey: .createdAt)
        let updatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .updatedAt)
        let deletedAtInt = try container.decodeIfPresent(Int64.self, forKey: .deleteDate)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt) / 1000) as NSDate
        
        if let updatedAtInt = updatedAtInt {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt) / 1000) as NSDate
        } else {
            updatedAt = nil
        }
        if let deletedAtInt = deletedAtInt {
            deleteDate = Date(timeIntervalSince1970: TimeInterval(deletedAtInt) / 1000) as NSDate
        } else {
            deleteDate = nil
        }
        if let rootdeleteDateInt = try container.decodeIfPresent(Int.self, forKey: .rootDeleteDate) {
            rootDeleteDate = Date(timeIntervalSince1970: TimeInterval(rootdeleteDateInt / 1000))
        } else {
            rootDeleteDate = nil
        }
        
        organizationId = try container.decodeIfPresent(Int64.self, forKey: .organizationId) ?? 0
        

	}
	
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let entity = entity as? Organization {
                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                entity.hasRoles = NSSet(array: hasRoles.map({ $0.getManagedObject(context: context) }))
                entity.hasContractLedgers = NSSet(array: hasContractLedgers.map({ $0.getManagedObject(context: context) }))
            }
        }
        
        if let entity: Organization = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Organization = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

}
