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

extension SheetEmptyEntity {
    
    var vSheetEmpty: VSheetEmpty {
        return VSheetEmpty(id: id, userUID: userUID, title: title, createdAt: createdAt, updatedAt: updatedAt, deleteDate: deleteDate, rootDeleteDate: rootDeleteDate as Date?, isEmptySheet: isEmptySheet, position: Int(position), time: time, hasTheme: hasTheme?.vTheme)
    }
}
