//
//  GoogleActivity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//


import Foundation
import CoreData

public class GoogleActivity: Entity {	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<GoogleActivity> {
		return NSFetchRequest<GoogleActivity>(entityName: "GoogleActivity")
	}
	
	@NSManaged public var endDate: NSDate?
	@NSManaged public var eventDescription: String?
	@NSManaged public var startDate: NSDate?
	
}
