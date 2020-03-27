//
//  VTheme.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class VTheme: VEntity {
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VTheme] {
		if UserDefaults.standard.object(forKey: secretKey) == nil {
			CoreTheme.predicates.append("isUniversal", equals: 0)
		}
		if let attributeName = attributeName, let ascending = ascending {
			CoreTheme.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreTheme.getEntities().map({ VTheme(theme: $0) })
	}
	
	class func single(with id: Int64?) -> VTheme? {
		if let id = id, let theme = CoreTheme.getEntitieWith(id: id) {
			return VTheme(theme: theme)
		}
		return nil
	}
	
	var allHaveTitle: Bool = false
	var backgroundColor: String? = nil
	var backgroundTransparancyNumber: Double = 0
	var displayTime: Bool = false
	var hasEmptySheet: Bool = false
	var imagePath: String? = nil
	var imagePathThumbnail: String? = nil
	var isBackgroundImageDeleted: Bool = false
	var isEmptySheetFirst: Bool = false
	var isHidden: Bool = false
	var isContentBold: Bool = false
	var isContentItalic: Bool = false
	var isContentUnderlined: Bool = false
	var isTitleBold: Bool = false
	var isTitleItalic: Bool = false
	var isTitleUnderlined: Bool = false
	var contentAlignmentNumber: Int16 = 0
	var contentBorderColorHex: String? = nil
	var contentBorderSize: Float = 0
	var contentFontName: String? = nil
	var contentTextColorHex: String? = nil
	var contentTextSize: Float = 0
	var position: Int16 = 0
	var titleAlignmentNumber: Int16 = 0
	var titleBackgroundColor: String? = nil
	var titleBorderColorHex: String? = nil
	var titleBorderSize: Float = 0
	var titleFontName: String? = nil
	var titleTextColorHex: String? = nil
	var titleTextSize: Float = 0
	var imagePathAWS: String? = nil
	var isUniversal: Bool = false

	var hasClusters: [VCluster] = []
	var hasSheets: [VSheet] = []
	
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
		case imagePathAWS
		case isUniversal
	}
	
	public override func initialization(decoder: Decoder) throws {
		try super.initialization(decoder: decoder)
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTheme.self)
		try container.encode(Int(truncating: NSNumber(value: allHaveTitle)), forKey: .allHaveTitle)
		try container.encode(backgroundColor, forKey: .backgroundColor)
		try container.encode(backgroundTransparancyNumber.description, forKey: .backgroundTransparancyNumber)
		try container.encode(Int(truncating: NSNumber(value: displayTime)), forKey: .displayTime)
		try container.encode(Int(truncating: NSNumber(value: hasEmptySheet)), forKey: .hasEmptySheet)
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
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		try container.encode(isUniversal, forKey: .isUniversal)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()

		let container = try decoder.container(keyedBy: CodingKeysTheme.self)
		isBackgroundImageDeleted = false
		allHaveTitle = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .allHaveTitle) ?? 0) as NSNumber)
		backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
		let transparencyString = try container.decodeIfPresent(String.self, forKey: .backgroundTransparancyNumber) ?? ""
		backgroundTransparancyNumber = Double(truncating: NSDecimalNumber(decimal:Decimal(string: transparencyString) ?? 0.0))
		displayTime = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .displayTime) ?? 0) as NSNumber)
		hasEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .hasEmptySheet) ?? 0) as NSNumber)
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
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		isUniversal = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isUniversal) ?? 0) as NSNumber)
		
		try super.initialization(decoder: decoder)

	}
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VTheme
		
		copy.allHaveTitle = self.allHaveTitle
		copy.backgroundColor = self.backgroundColor
		copy.backgroundTransparancyNumber = self.backgroundTransparancyNumber
		copy.displayTime = self.displayTime
		copy.hasEmptySheet = self.hasEmptySheet
		copy.imagePath = self.imagePath
		copy.imagePathThumbnail = self.imagePathThumbnail
		copy.isBackgroundImageDeleted = self.isBackgroundImageDeleted
		copy.isEmptySheetFirst = self.isEmptySheetFirst
		copy.isHidden = self.isHidden
		copy.isContentBold = self.isContentBold
		copy.isContentItalic = self.isContentItalic
		copy.isContentUnderlined = self.isContentUnderlined
		copy.isTitleBold = self.isTitleBold
		copy.isTitleItalic = self.isTitleItalic
		copy.isTitleUnderlined = self.isTitleUnderlined
		copy.contentAlignmentNumber = self.contentAlignmentNumber
		copy.contentBorderColorHex = self.contentBorderColorHex
		copy.contentBorderSize = self.contentBorderSize
		copy.contentFontName = self.contentFontName
		copy.contentTextColorHex = self.contentTextColorHex
		copy.contentTextSize = self.contentTextSize
		copy.position = self.position
		copy.titleAlignmentNumber = self.titleAlignmentNumber
		copy.titleBackgroundColor = self.titleBackgroundColor
		copy.titleBorderColorHex = self.titleBorderColorHex
		copy.titleBorderSize = self.titleBorderSize
		copy.titleFontName = self.titleFontName
		copy.titleTextColorHex = self.titleTextColorHex
		copy.titleTextSize = self.titleTextSize
		copy.imagePathAWS = self.imagePathAWS
		copy.hasClusters = self.hasClusters
		copy.hasSheets = self.hasSheets
		copy.isUniversal = self.isUniversal
		
		return copy
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		
		if let theme = entity as? Theme {
			
			theme.allHaveTitle = self.allHaveTitle
			theme.backgroundColor = self.backgroundColor
			theme.backgroundTransparancyNumber = self.backgroundTransparancyNumber
			theme.displayTime = self.displayTime
			theme.hasEmptySheet = self.hasEmptySheet
			theme.imagePath = self.imagePath
			theme.imagePathThumbnail = self.imagePathThumbnail
			if imagePathAWS == nil {
				theme.imagePath = nil
				theme.imagePathThumbnail = nil
			}
			theme.isBackgroundImageDeleted = self.isBackgroundImageDeleted
			theme.isEmptySheetFirst = self.isEmptySheetFirst
			theme.isHidden = self.isHidden
			theme.isContentBold = self.isContentBold
			theme.isContentItalic = self.isContentItalic
			theme.isContentUnderlined = self.isContentUnderlined
			theme.isTitleBold = self.isTitleBold
			theme.isTitleItalic = self.isTitleItalic
			theme.isTitleUnderlined = self.isTitleUnderlined
			theme.contentAlignmentNumber = self.contentAlignmentNumber
			theme.contentBorderColorHex = self.contentBorderColorHex
			theme.contentBorderSize = self.contentBorderSize
			theme.contentFontName = self.contentFontName
			theme.contentTextColorHex = self.contentTextColorHex
			theme.contentTextSize = self.contentTextSize
			theme.position = self.position
			theme.titleAlignmentNumber = self.titleAlignmentNumber
			theme.titleBackgroundColor = self.titleBackgroundColor
			theme.titleBorderColorHex = self.titleBorderColorHex
			theme.titleBorderSize = self.titleBorderSize
			theme.titleFontName = self.titleFontName
			theme.titleTextColorHex = self.titleTextColorHex
			theme.titleTextSize = self.titleTextSize
			theme.imagePathAWS = self.imagePathAWS
			theme.isUniversal = self.isUniversal
						
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		
		if let theme = entity as? Theme {
			allHaveTitle = theme.allHaveTitle
			backgroundColor = theme.backgroundColor
			backgroundTransparancyNumber = theme.backgroundTransparancyNumber
			displayTime = theme.displayTime
			hasEmptySheet = theme.hasEmptySheet
			imagePath = theme.imagePath
			imagePathThumbnail = theme.imagePathThumbnail
			isBackgroundImageDeleted = theme.isBackgroundImageDeleted
			isEmptySheetFirst = theme.isEmptySheetFirst
			isHidden = theme.isHidden
			isContentBold = theme.isContentBold
			isContentItalic = theme.isContentItalic
			isContentUnderlined = theme.isContentUnderlined
			isTitleBold = theme.isTitleBold
			isTitleItalic = theme.isTitleItalic
			isTitleUnderlined = theme.isTitleUnderlined
			contentAlignmentNumber = theme.contentAlignmentNumber
			contentBorderColorHex = theme.contentBorderColorHex
			contentBorderSize = theme.contentBorderSize
			contentFontName = theme.contentFontName
			contentTextColorHex = theme.contentTextColorHex
			contentTextSize = theme.contentTextSize
			position = theme.position
			titleAlignmentNumber = theme.titleAlignmentNumber
			titleBackgroundColor = theme.titleBackgroundColor
			titleBorderColorHex = theme.titleBorderColorHex
			titleBorderSize = theme.titleBorderSize
			titleFontName = theme.titleFontName
			titleTextColorHex = theme.titleTextColorHex
			titleTextSize = theme.titleTextSize
			imagePathAWS = theme.imagePathAWS
			isUniversal = theme.isUniversal
		}
	}
	
	convenience init(theme: Theme) {
		self.init()
		getPropertiesFrom(entity: theme)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreTheme.managedObjectContext = context
		if let storedEntity = CoreTheme.getEntitieWith(id: id) {
			CoreTheme.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreTheme.managedObjectContext = context
			let newEntity = CoreTheme.createEntityNOTsave()
			CoreTheme.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
}



extension VTheme {
	
	// theme as other theme
	/// entity (Base) properties  will not be overridden
	func getValues(from: VTheme) {
		allHaveTitle = from.allHaveTitle
		backgroundColor = from.backgroundColor
		backgroundTransparancyNumber = from.backgroundTransparancyNumber
		displayTime = from.displayTime
		hasEmptySheet = from.hasEmptySheet
		imagePath = from.imagePath
		imagePathThumbnail = from.imagePathThumbnail
		isBackgroundImageDeleted = from.isBackgroundImageDeleted
		isEmptySheetFirst = from.isEmptySheetFirst
		isContentBold = from.isContentBold
		isContentItalic = from.isContentItalic
		isContentUnderlined = from.isContentUnderlined
		isTitleBold = from.isTitleBold
		isTitleItalic = from.isTitleItalic
		isTitleUnderlined = from.isTitleUnderlined
		contentAlignmentNumber = from.contentAlignmentNumber
		contentBorderColorHex = from.contentBorderColorHex
		contentBorderSize = from.contentBorderSize
		contentFontName = from.contentFontName
		contentTextColorHex = from.contentTextColorHex
		contentTextSize = from.contentTextSize
		position = from.position
		titleAlignmentNumber = from.titleAlignmentNumber
		titleBackgroundColor = from.titleBackgroundColor
		titleBorderColorHex = from.titleBorderColorHex
		titleBorderSize = from.titleBorderSize
		titleFontName = from.titleFontName
		titleTextColorHex = from.titleTextColorHex
		titleTextSize = from.titleTextSize
		imagePathAWS = from.imagePathAWS
		isUniversal = from.isUniversal
	}

}


extension VTheme {
	var uploadImagesObjecs: [UploadObject] {
		let imagePaths = [imagePath]
		return imagePaths.compactMap({ URL(string: $0) }).compactMap({ UploadObject(localURL: $0) })
	}
	
	var downloadImagesObjects: [DownloadObject] {
		var imagePaths = [imagePathAWS]
		if imagePath != nil {
			imagePaths = []
		}
		return imagePaths.compactMap({ URL(string: $0) }).compactMap({ DownloadObject(remoteURL: $0) })
	}
	
	func setUploadValues(_ uploadObjects: [UploadObject]) {
		for upload in uploadObjects {
			if let imagePath = imagePath {
				if imagePath == upload.localURL.absoluteString {
					imagePathAWS = upload.remoteURL?.absoluteString
				}
			}
		}
	}
	
	func setDownloadValues(_ downloadObjects: [DownloadObject]) {
		for download in downloadObjects {
			if let imagePathAWS = imagePathAWS {
				if imagePathAWS == download.remoteURL.absoluteString {
					self.imagePath = download.localURL?.absoluteString
					imagePathThumbnail = download.localThumbURL?.absoluteString
				}
			}
		}
	}
	
}
