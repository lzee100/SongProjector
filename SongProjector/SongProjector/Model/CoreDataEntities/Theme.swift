//
//  Theme.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol bla {
	func bla()
}

public class Theme: Entity {
	
//	@nonobjc public class func fetchRequest() -> NSFetchRequest<Theme> {
//		return NSFetchRequest<Theme>(entityName: "Theme")
//	}
	
	@NSManaged public var allHaveTitle: Bool
	@NSManaged public var backgroundColor: String?
	@NSManaged public var backgroundTransparancyNumber: Double
	@NSManaged public var displayTime: Bool
	@NSManaged public var hasEmptySheet: Bool
	@NSManaged public var imagePath: String?
	@NSManaged public var imagePathThumbnail: String?
	@NSManaged public var isTempSelectedImageDeleted: Bool
	@NSManaged public var isEmptySheetFirst: Bool
	@NSManaged public var isHidden: Bool
	@NSManaged public var isContentBold: Bool
	@NSManaged public var isContentItalic: Bool
	@NSManaged public var isContentUnderlined: Bool
	@NSManaged public var isTitleBold: Bool
	@NSManaged public var isTitleItalic: Bool
	@NSManaged public var isTitleUnderlined: Bool
	@NSManaged public var contentAlignmentNumber: Int16
	@NSManaged public var contentBorderColorHex: String?
	@NSManaged public var contentBorderSize: Float
	@NSManaged public var contentFontName: String?
	@NSManaged public var contentTextColorHex: String?
	@NSManaged public var contentTextSize: Float
	@NSManaged public var position: Int16
	@NSManaged public var titleAlignmentNumber: Int16
	@NSManaged public var titleBackgroundColor: String?
	@NSManaged public var titleBorderColorHex: String?
	@NSManaged public var titleBorderSize: Float
	@NSManaged public var titleFontName: String?
	@NSManaged public var titleTextColorHex: String?
	@NSManaged public var titleTextSize: Float
	@NSManaged public var imagePathThumbnailAWS: String?
	@NSManaged public var imagePathAWS: String?
	@NSManaged public var isUniversal: Bool
    @NSManaged public var isDeletable: Bool
    

	@NSManaged public var hasClusters: NSSet?
	@NSManaged public var hasSheets: NSSet?
	
}

// MARK: Generated accessors for hasSheets
extension Theme {
	
	@objc(addHasSheetsObject:)
	@NSManaged public func addToHasSheets(_ value: Sheet)
	
	@objc(removeHasSheetsObject:)
	@NSManaged public func removeFromHasSheets(_ value: Sheet)
	
	@objc(addHasSheets:)
	@NSManaged public func addToHasSheets(_ values: NSSet)
	
	@objc(removeHasSheets:)
	@NSManaged public func removeFromHasSheets(_ values: NSSet)
	
}
