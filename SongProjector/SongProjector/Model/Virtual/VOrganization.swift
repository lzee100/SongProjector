//
//  VOrganization.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VOrganization: VEntity {
	
    var hasRoles: [VRole] = []
	var hasContractLedgers: [VContractLedger] = []
	
	
	enum CodingKeysOrganization:String,CodingKey
	{
		case hasRoles = "roles"
		case hasContractLedgers = "contractLedgers"
		case name
	}
	
	
	
	// MARK: - Init
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysOrganization.self)
		hasRoles = try container.decodeIfPresent([VRole].self, forKey: .hasRoles) ?? []
		hasContractLedgers = try container.decodeIfPresent([VContractLedger].self, forKey: .hasContractLedgers) ?? []
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysOrganization.self)
		try container.encode(hasRoles, forKey: .hasRoles)
		try container.encode(hasContractLedgers, forKey: .hasContractLedgers)
		try super.encode(to: encoder)
		try container.encode(title, forKey: .name)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysOrganization.self)
		self.hasRoles = try (container.decodeIfPresent([VRole].self, forKey: .hasRoles) ?? [])
		self.hasContractLedgers = try container.decodeIfPresent([VContractLedger].self, forKey: .hasContractLedgers) ?? []
		
		try super.initialization(decoder: decoder)
		self.title = try container.decodeIfPresent(String.self, forKey: .name)

	}
	
//	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
//		super.setPropertiesTo(entity: entity, context: context)
//		if let organization = entity as? Organization {
//			organization.hasRoles = NSSet(array: hasRoles.map({ $0.getManagedObject(context: context) }))
//			organization.hasContractLedgers = NSSet(array: hasContractLedgers.map({ $0.getManagedObject(context: context) }))
//		}
//	}
//
//    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
//        super.getPropertiesFrom(entity: entity, context: context)
//		if let organization = entity as? Organization {
//            hasRoles = (organization.hasRoles?.allObjects as? [Role] ?? []).map({ VRole(entity: $0, context: context) })
//            hasContractLedgers = (organization.hasContractLedgers?.allObjects as? [ContractLedger] ?? []).map({ VContractLedger(entity: $0, context: context) })
//		}
//	}
	
	convenience init(organization: Organization, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: organization, context: context)
	}
	
//    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
//        if let entity: Organization = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        } else {
//            let entity: Organization = DataFetcher().createEntity(moc: context)
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        }
//    }

}
