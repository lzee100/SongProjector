//
//  Organization.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class Organization: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Organization> {
		return NSFetchRequest<Organization>(entityName: "Organization")
	}
	
	@NSManaged public var hasRoles: NSSet?
	
	enum CodingKeysOrganization:String,CodingKey
	{
		case hasRoles = "role"
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysOrganization.self)
		let roles = try container.decodeIfPresent([Role].self, forKey: .hasRoles)
		if let roles = roles {
			self.hasRoles = NSSet(array: roles)
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysOrganization.self)
		if let roles = hasRoles?.allObjects as? [Role] {
			try container.encode(roles, forKey: .hasRoles)
		}
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Organization", in: managedObjectContext) else {
			fatalError("failed at Organization")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		//		try self.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeysOrganization.self)
		let roles = try container.decodeIfPresent([Role].self, forKey: .hasRoles)
		if let roles = roles {
			self.hasRoles = NSSet(array: roles)
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	
}


// MARK: Generated accessors for hasRoles
extension Organization {
	
	@objc(addHasRolesObject:)
	@NSManaged public func addToHasRoles(_ value: Role)
	
	@objc(removeHasRolesObject:)
	@NSManaged public func removeFromHasRoles(_ value: Role)
	
	@objc(addHasRoles:)
	@NSManaged public func addToHasRoles(_ values: NSSet)
	
	@objc(removeHasRoles:)
	@NSManaged public func removeFromHasRoles(_ values: NSSet)
	
}
