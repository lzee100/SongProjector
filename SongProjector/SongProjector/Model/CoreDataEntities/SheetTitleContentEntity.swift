//
//  SheetTitleContentEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class SheetTitleContentEntity: Sheet {
	static var type: SheetType {
		return .SheetTitleContent
	}
	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetTitleContentEntity> {
		return NSFetchRequest<SheetTitleContentEntity>(entityName: "SheetTitleContentEntity")
	}
	
	@NSManaged public var content: String?
    @NSManaged public var isBibleVers: Bool

}
