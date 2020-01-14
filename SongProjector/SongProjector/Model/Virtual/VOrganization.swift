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
	
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VOrganization] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreOrganization.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreOrganization.getEntities().map({ VOrganization(organization: $0) })
	}
	
	class func single(with id: Int64?) -> VOrganization? {
		if let id = id, let organization = CoreOrganization.getEntitieWith(id: id) {
			return VOrganization(organization: organization)
		}
		return nil
	}
	
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
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let organization = entity as? Organization {
			organization.hasRoles = NSSet(array: hasRoles.map({ $0.getManagedObject(context: context) }))
			organization.hasContractLedgers = NSSet(array: hasContractLedgers.map({ $0.getManagedObject(context: context) }))
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let organization = entity as? Organization {
			hasRoles = (organization.hasRoles?.allObjects as? [Role] ?? []).map({ VRole(entity: $0) })
			hasContractLedgers = (organization.hasContractLedgers?.allObjects as? [ContractLedger] ?? []).map({ VContractLedger(entity: $0) })
		}
	}
	
	convenience init(organization: Organization) {
		self.init()
		getPropertiesFrom(entity: organization)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreOrganization.managedObjectContext = context
		if let storedEntity = CoreOrganization.getEntitieWith(id: id) {
			CoreOrganization.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreOrganization.managedObjectContext = context
			let newEntity = CoreOrganization.createEntityNOTsave()
			CoreOrganization.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
}
