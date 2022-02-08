//
//  SheetPastorsEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class SheetPastorsEntity: Sheet {
	
	static var type: SheetType {
		return .SheetPastors
	}
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetPastorsEntity> {
		return NSFetchRequest<SheetPastorsEntity>(entityName: "SheetPastorsEntity")
	}
	
	@NSManaged public var content: String?
	@NSManaged public var imagePath: String?
	@NSManaged public var thumbnailPath: String?
	@NSManaged public var imagePathAWS: String?
	@NSManaged public var thumbnailPathAWS: String?
	
	

}

extension SheetPastorsEntity {
    var vSheetPastors: VSheetPastors {
        return VSheetPastors(id: id, userUID: userUID, title: title, createdAt: createdAt, updatedAt: updatedAt, deleteDate: deleteDate, rootDeleteDate: rootDeleteDate as Date?, isEmptySheet: isEmptySheet, position: Int(position), time: time, hasTheme: hasTheme?.vTheme, content: content, imagePath: imagePath, thumbnailPath: thumbnailPath, imagePathAWS: imagePathAWS, thumbnailPathAWS: thumbnailPathAWS)
    }
}
