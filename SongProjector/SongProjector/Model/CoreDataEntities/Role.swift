//
//  Role.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class Role: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Role> {
		return NSFetchRequest<Role>(entityName: "Role")
	}
	
	@NSManaged public var organizationId: Int64
	@NSManaged public var hasOrganization: Organization?
	@NSManaged public var hasUsers: NSSet?
	
	enum CodingKeysRole:String,CodingKey
	{
		case hasOrganization = "organization"
		case hasUsers = "user"
		case organizationId = "organization_id"
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysRole.self)

		let hasUsers = try container.decodeIfPresent([User].self, forKey: .hasUsers)
		if let users = hasUsers {
			self.hasUsers = NSSet(array: users)
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysRole.self)
		if let organization = hasOrganization {
			try container.encode(organization, forKey: .hasOrganization)
		} else {
			CoreOrganization.managedObjectContext = mocBackground
			if let org = CoreOrganization.getEntitieWith(id: id) {
				try container.encode(org, forKey: .hasOrganization)
			}
		}
		if let users = hasUsers?.allObjects as? [User] {
			try container.encode(users, forKey: .hasUsers)
		}
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Role", in: managedObjectContext) else {
			fatalError("failed at Role")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysRole.self)
		organizationId = try container.decodeIfPresent(Int64.self, forKey: .organizationId) ?? 0
		let users = try container.decodeIfPresent([User].self, forKey: .hasUsers)
		if let users = users {
			hasUsers = NSSet(array: users)
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	
}




// MARK: Generated accessors for hasUser
extension Role {
	
	@objc(addHasUserObject:)
	@NSManaged public func addToHasUser(_ value: User)
	
	@objc(removeHasUserObject:)
	@NSManaged public func removeFromHasUser(_ value: User)
	
	@objc(addHasUser:)
	@NSManaged public func addToHasUser(_ values: NSSet)
	
	@objc(removeHasUser:)
	@NSManaged public func removeFromHasUser(_ values: NSSet)
	
}
