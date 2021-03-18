//
//  SheetSplitEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class SheetSplitEntity: Sheet {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetSplitEntity> {
		return NSFetchRequest<SheetSplitEntity>(entityName: "SheetSplitEntity")
	}
	
	@NSManaged public var textLeft: String?
	@NSManaged public var textRight: String?
	
}
