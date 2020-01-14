//
//  VRole.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VRole: VEntity {
	
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VRole] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreRole.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreRole.getEntities().map({ VRole(role: $0) })
	}
	
	class func single(with id: Int64?) -> VRole? {
		if let id = id, let role = CoreRole.getEntitieWith(id: id) {
			return VRole(role: role)
		}
		return nil
	}
	
	var organizationId: Int64 = 0
	var hasOrganization: Organization? = nil
	
	enum CodingKeysRole:String,CodingKey
	{
		case hasOrganization = "organization"
		case organizationId = "organization_id"
	}
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		//		var container = encoder.container(keyedBy: CodingKeysRole.self)
		// circle effect, user has role, role has user (unending circle of encoding)
		//		if let organization = hasOrganization {
		//			try container.encode(organization, forKey: .hasOrganization)
		//		} else {
		//			CoreOrganization.managedObjectContext = mocBackground
		//			if let org = CoreOrganization.getEntitieWith(id: id) {
		//				try container.encode(org, forKey: .hasOrganization)
		//			}
		//		}
		//		if let users = hasUsers?.allObjects as? [User] {
		//			try container.encode(users, forKey: .hasUsers)
		//		}
		
		try super.encode(to: encoder)
	}
	
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysRole.self)
		
		organizationId = try container.decodeIfPresent(Int64.self, forKey: .organizationId) ?? 0
		
		//		let hasUsers = try container.decodeIfPresent([User].self, forKey: .hasUsers)
		//		if let users = hasUsers {
		//			self.hasUsers = NSSet(array: users)
		//		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysRole.self)
		organizationId = try container.decodeIfPresent(Int64.self, forKey: .organizationId) ?? 0
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let role = entity as? Role {
			role.organizationId = self.organizationId
			role.hasOrganization = self.hasOrganization
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let role = entity as? Role {
			organizationId = role.organizationId
			hasOrganization = role.hasOrganization
		}
	}
	
	convenience init(role: Role) {
		self.init()
		getPropertiesFrom(entity: role)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreRole.managedObjectContext = context
		if let storedEntity = CoreRole.getEntitieWith(id: id) {
			CoreRole.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreRole.managedObjectContext = context
			let newEntity = CoreRole.createEntityNOTsave()
			CoreRole.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}
		
	}
	
}
