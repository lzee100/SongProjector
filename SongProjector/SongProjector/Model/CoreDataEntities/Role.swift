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
