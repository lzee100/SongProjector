//
//  SheetActivities.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData



class SheetActivitiesEntity: Sheet {
	static var type: SheetType {
		return .SheetActivities
	}
	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetActivitiesEntity> {
		return NSFetchRequest<SheetActivitiesEntity>(entityName: "SheetActivities")
	}
	
	@NSManaged public var hasGoogleActivity: NSSet?
	
}


