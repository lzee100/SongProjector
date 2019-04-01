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
	@NSManaged public var backgroundTransparancyNumber: Float
	@NSManaged public var displayTime: Bool
	@NSManaged public var hasEmptySheet: Bool
	@NSManaged public var imagePath: String?
	@NSManaged public var imagePathThumbnail: String?
	@NSManaged public var isBackgroundImageDeleted: Bool
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

	@NSManaged public var hasClusters: NSSet?
	@NSManaged public var hasSheets: NSSet?
	@NSManaged public var hasInstruments: NSSet?
	
	enum CodingKeysTheme:String,CodingKey
	{
		case allHaveTitle
		case backgroundColor
		case backgroundTransparancyNumber = "backgroundTransparancy"
		case displayTime
		case hasEmptySheet
		case imagePath
		case imagePathThumbnail
		case isEmptySheetFirst
		case isHidden
		case isContentBold
		case isContentItalic
		case isContentUnderlined
		case isTitleBold
		case isTitleItalic
		case isTitleUnderlined
		case contentAlignment  = "contentAlignmentNumber"
		case contentBorderColorHex = "contentBorderColor"
		case contentBorderSize
		case contentFontName
		case contentTextColorHex = "contentTextColor"
		case contentTextSize
		case position
		case titleAlignment = "titleAlignmentNumber"
		case titleBackgroundColor
		case titleBorderColorHex = "titleBorderColor"
		case titleBorderSize
		case titleFontName
		case titleTextColorHex = "titleTextColor"
		case titleTextSize
		case imagePathThumbnailAWS
		case imagePathAWS
	}
	
	
	
	// MARK: - Init

	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTheme.self)
		try container.encode(Int(truncating: NSNumber(value: allHaveTitle)), forKey: .allHaveTitle)
		try container.encode(backgroundColor, forKey: .backgroundColor)
		try container.encode(backgroundTransparancyNumber, forKey: .backgroundTransparancyNumber)
		try container.encode(Int(truncating: NSNumber(value: displayTime)), forKey: .displayTime)
		try container.encode(Int(truncating: NSNumber(value: hasEmptySheet)), forKey: .hasEmptySheet)
		try container.encode(imagePath, forKey: .imagePath)
		try container.encode(imagePathThumbnail, forKey: .imagePathThumbnail)
		try container.encode(Int(truncating: NSNumber(value: isEmptySheetFirst)), forKey: .isEmptySheetFirst)
		try container.encode(Int(truncating: NSNumber(value: isHidden)), forKey: .isHidden)
		try container.encode(Int(truncating: NSNumber(value: isContentBold)), forKey: .isContentBold)
		try container.encode(Int(truncating: NSNumber(value: isContentItalic)), forKey: .isContentItalic)
		try container.encode(Int(truncating: NSNumber(value: isContentUnderlined)), forKey: .isContentUnderlined)
		try container.encode(Int(truncating: NSNumber(value: isTitleBold)), forKey: .isTitleBold)
		try container.encode(Int(truncating: NSNumber(value: isTitleItalic)), forKey: .isTitleItalic)
		try container.encode(Int(truncating: NSNumber(value: isTitleUnderlined)), forKey: .isTitleUnderlined)
		try container.encode(contentAlignmentNumber, forKey: .contentAlignment)
		try container.encode(contentBorderColorHex, forKey: .contentBorderColorHex)
		try container.encode(contentBorderSize, forKey: .contentBorderSize)
		try container.encode(contentFontName, forKey: .contentFontName)
		try container.encode(contentTextColorHex, forKey: .contentTextColorHex)
		try container.encode(contentTextSize, forKey: .contentTextSize)
		try container.encode(position, forKey: .position)
		try container.encode(titleAlignmentNumber, forKey: .titleAlignment)
		try container.encode(titleBackgroundColor, forKey: .titleBackgroundColor)
		try container.encode(titleBorderColorHex, forKey: .titleBorderColorHex)
		try container.encode(titleBorderSize, forKey: .titleBorderSize)
		try container.encode(titleFontName, forKey: .titleFontName)
		try container.encode(titleTextColorHex, forKey: .titleTextColorHex)
		try container.encode(titleTextSize, forKey: .titleTextSize)
		try container.encode(imagePathThumbnailAWS, forKey: .imagePathThumbnailAWS)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Theme", in: managedObjectContext) else {
				fatalError("failed at theme")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)

		let container = try decoder.container(keyedBy: CodingKeysTheme.self)
		isBackgroundImageDeleted = false
		allHaveTitle = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .allHaveTitle) ?? 0) as NSNumber)
		backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
		backgroundTransparancyNumber = try container.decodeIfPresent(Float.self, forKey: .backgroundTransparancyNumber) ?? 0
		displayTime = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .displayTime) ?? 0) as NSNumber)
		hasEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .hasEmptySheet) ?? 0) as NSNumber)
		imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
		imagePathThumbnail = try container.decodeIfPresent(String.self, forKey: .imagePathThumbnail)
		isEmptySheetFirst = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isEmptySheetFirst) ?? 0) as NSNumber)
		isHidden = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isHidden) ?? 0) as NSNumber)
		isContentBold = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentBold) ?? 0) as NSNumber)
		isContentItalic = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentItalic) ?? 0) as NSNumber)
		isContentUnderlined = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentUnderlined) ?? 0) as NSNumber)
		isTitleBold = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleBold) ?? 0) as NSNumber)
		isTitleItalic = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleItalic) ?? 0) as NSNumber)
		isTitleUnderlined = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleUnderlined) ?? 0) as NSNumber)
		contentAlignmentNumber = try container.decodeIfPresent(Int16.self, forKey: .contentAlignment) ?? 0
		contentBorderColorHex = try container.decodeIfPresent(String.self, forKey: .contentBorderColorHex)
		contentBorderSize = try container.decodeIfPresent(Float.self, forKey: .contentBorderSize) ?? 14
		contentFontName = try container.decodeIfPresent(String.self, forKey: .contentFontName)
		contentTextColorHex = try container.decodeIfPresent(String.self, forKey: .contentTextColorHex)
		contentTextSize = try container.decodeIfPresent(Float.self, forKey: .contentTextSize) ?? 14
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
		titleAlignmentNumber = try container.decodeIfPresent(Int16.self, forKey: .titleAlignment) ?? 0
		titleBackgroundColor = try container.decodeIfPresent(String.self, forKey: .titleBackgroundColor)
		titleBorderColorHex = try container.decodeIfPresent(String.self, forKey: .titleBorderColorHex)
		titleBorderSize = try container.decodeIfPresent(Float.self, forKey: .titleBorderSize) ?? 0
		titleFontName = try container.decodeIfPresent(String.self, forKey: .titleFontName)
		titleTextColorHex = try container.decodeIfPresent(String.self, forKey: .titleTextColorHex)
		titleTextSize = try container.decodeIfPresent(Float.self, forKey: .titleTextSize) ?? 14
		imagePathThumbnailAWS = try container.decodeIfPresent(String.self, forKey: .imagePathThumbnailAWS)
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		
		try super.initialization(decoder: decoder)

	}
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreTheme.createEntityNOTsave()
		for key in self.entity.propertiesByName.keys {
			if key != "id" {
				let value: Any? = self.value(forKey: key)
				entity.setValue(value, forKey: key)
			}
		}
		isTemp = true
		return entity
	}
	
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

// MARK: Generated accessors for hasClusters
extension Theme {
	
	@objc(addHasClustersObject:)
	@NSManaged public func addToHasClusters(_ value: Cluster)
	
	@objc(removeHasClustersObject:)
	@NSManaged public func removeFromHasClusters(_ value: Cluster)
	
	@objc(addHasClusters:)
	@NSManaged public func addToHasClusters(_ values: NSSet)
	
	@objc(removeHasClusters:)
	@NSManaged public func removeFromHasClusters(_ values: NSSet)
	
}
