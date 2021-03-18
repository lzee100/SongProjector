//
//  Entity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Entity: NSManagedObject {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
		return NSFetchRequest<Entity>(entityName: "Entity")
	} 
	
	@NSManaged public var id: String
    @NSManaged public var userUID: String
	@NSManaged public var title: String?
	@NSManaged public var createdAt: NSDate
	@NSManaged public var updatedAt: NSDate?
	@NSManaged public var deleteDate: NSDate?
	@NSManaged public var isTemp: Bool
    @NSManaged public var rootDeleteDate: NSDate?

}
