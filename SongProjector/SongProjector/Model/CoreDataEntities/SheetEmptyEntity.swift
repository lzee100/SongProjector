//
//  SheetEmptyEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//


import Foundation
import CoreData

public class SheetEmptyEntity: Sheet {
	static var type: SheetType = .SheetEmpty
	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetEmptyEntity> {
		return NSFetchRequest<SheetEmptyEntity>(entityName: "SheetEmptyEntity")
	}
    
}
