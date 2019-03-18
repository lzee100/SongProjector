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
	@NSManaged public var hasContractLedgers: NSSet?
	
	
	enum CodingKeysOrganization:String,CodingKey
	{
		case hasRoles = "roles"
		case hasContractLedgers = "contractLedgers"
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
		
		let contractLedgers = try container.decodeIfPresent([ContractLedger].self, forKey: .hasContractLedgers)
		if let contractLedgers = contractLedgers {
			self.hasContractLedgers = NSSet(array: contractLedgers)
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysOrganization.self)
		if let roles = hasRoles?.allObjects as? [Role] {
			try container.encode(roles, forKey: .hasRoles)
		}
		if let contractLedgers = hasContractLedgers?.allObjects as? [ContractLedger] {
			try container.encode(contractLedgers, forKey: .hasContractLedgers)
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
		
		let contractLedgers = try container.decodeIfPresent([ContractLedger].self, forKey: .hasContractLedgers)
		if let contractLedgers = contractLedgers {
			self.hasContractLedgers = NSSet(array: contractLedgers)
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

// MARK: Generated accessors for hasContractLedgers
extension Organization {
	
	@objc(addHasContractLedgersObject:)
	@NSManaged public func addToHasContractLedgers(_ value: ContractLedger)
	
	@objc(removeHasContractLedgersObject:)
	@NSManaged public func removeFromHasContractLedgers(_ value: ContractLedger)
	
	@objc(addHasContractLedgers:)
	@NSManaged public func addToHasContractLedgers(_ values: NSSet)
	
	@objc(removeHasContractLedgers:)
	@NSManaged public func removeFromHasContractLedgers(_ values: NSSet)
	
}
