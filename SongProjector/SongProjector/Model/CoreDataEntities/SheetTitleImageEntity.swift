//
//  SheetTitleImageEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class SheetTitleImageEntity: Sheet {
	static var type: SheetType {
		return .SheetTitleImage
	}
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetTitleImageEntity> {
		return NSFetchRequest<SheetTitleImageEntity>(entityName: "SheetTitleImageEntity")
	}
	
	@NSManaged public var content: String?
	@NSManaged public var hasTitle: Bool
	@NSManaged public var imageBorderColor: String?
	@NSManaged public var imageBorderSize: Int16
	@NSManaged public var imageContentMode: Int16
	@NSManaged public var imageHasBorder: Bool
	@NSManaged public var imagePath: String?
	@NSManaged public var thumbnailPath: String?
	@NSManaged public var thumbnailPathAWS: String?
	@NSManaged public var imagePathAWS: String?
	
}

extension SheetTitleImageEntity {
    
    var vSheetTitleImage: VSheetTitleImage {
        return VSheetTitleImage(id: id, userUID: userUID, title: title, createdAt: createdAt, updatedAt: updatedAt, deleteDate: deleteDate, rootDeleteDate: rootDeleteDate as Date?, isEmptySheet: isEmptySheet, position: Int(position), time: time, hasTheme: hasTheme?.vTheme, content: content, hasTitle: hasTitle, imageBorderColor: imageBorderColor, imageBorderSize: imageBorderSize, imageContentMode: imageContentMode, imageHasBorder: imageHasBorder, imagePath: imagePath, thumbnailPath: thumbnailPath, imagePathAWS: imagePathAWS)
    }
}
