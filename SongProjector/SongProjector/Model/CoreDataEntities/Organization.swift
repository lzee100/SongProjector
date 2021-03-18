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
