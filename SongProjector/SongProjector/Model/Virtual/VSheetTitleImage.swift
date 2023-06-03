//
//  VSheetTitleImage.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VSheetTitleImage: VSheet, VSheetMetaType {
	
	static var type: SheetType = .SheetTitleImage

	var content: String? = nil
	var hasTitle: Bool = true
	var imageBorderColor: String? = nil
	var imageBorderSize: Int16 = 0
	var imageContentMode: Int16 = 0
	var imageHasBorder: Bool = false
    var imagePath: String? = nil
	var thumbnailPath: String? = nil
	var imagePathAWS: String? = nil
    
    var tempSelectedImage: UIImage? {
        didSet {
            tempSelectedImageThumbNail = tempSelectedImage?.resized(withPercentage: 0.5)
        }
    }
    var tempSelectedImageThumbNail: UIImage?
    var isTempSelectedImageDeleted = false
    var tempLocalImageName: String?
    
    var hasNewRemoteImage: Bool {
        if let imagePathAWS = imagePathAWS {
            if
                let imagePath = imagePath,
                let url = URL(string: imagePath),
                let remoteURL = URL(string: imagePathAWS),
                url.lastPathComponent == remoteURL.lastPathComponent
            {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
	
	
	enum CodingKeysTitleImage:String,CodingKey
	{
		case content
		case hasTitle
		case imageBorderColor
		case imageBorderSize
		case imageContentMode
		case imageHasBorder
		case thumbnailPathAWS
		case imagePathAWS
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTitleImage.self)
		try container.encode(Int(truncating: NSNumber(value: hasTitle)), forKey: .hasTitle)
		try container.encode(content, forKey: .content)
		try container.encode(imageBorderColor, forKey: .imageBorderColor)
		try container.encode(imageBorderSize, forKey: .imageBorderSize)
		try container.encode(imageContentMode, forKey: .imageContentMode)
		try container.encode(Int(truncating: NSNumber(value: imageHasBorder)), forKey: .imageHasBorder)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysTitleImage.self)
		hasTitle = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .hasTitle) ?? 0) as NSNumber)
		imageBorderColor = try container.decodeIfPresent(String.self, forKey: .imageBorderColor)
		content = try container.decodeIfPresent(String.self, forKey: .content)
		imageBorderSize = try container.decodeIfPresent(Int16.self, forKey: .imageBorderSize) ?? 0
		imageContentMode = try container.decodeIfPresent(Int16.self, forKey: .imageContentMode) ?? 0
		imageHasBorder = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .imageHasBorder) ?? 0) as NSNumber)
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetTitleImage
		copy.content = content
		copy.hasTitle = hasTitle
		copy.imageBorderColor = imageBorderColor
		copy.imageBorderSize = imageBorderSize
		copy.imageContentMode = imageContentMode
		copy.imageHasBorder = imageHasBorder
		copy.imagePath = imagePath
		copy.thumbnailPath = thumbnailPath
		copy.imagePathAWS = imagePathAWS
		return copy
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheet = entity as? SheetTitleImageEntity {
			sheet.content = content
			sheet.hasTitle = hasTitle
			sheet.imageBorderColor = imageBorderColor
			sheet.imageBorderSize = imageBorderSize
			sheet.imageContentMode = imageContentMode
            sheet.imageHasBorder = imageHasBorder
			sheet.imagePathAWS = imagePathAWS
            sheet.imagePath = imagePath
            sheet.thumbnailPath = thumbnailPath
		}
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {		super.getPropertiesFrom(entity: entity, context: context)
		if let sheet = entity as? SheetTitleImageEntity {
			content = sheet.content
			hasTitle = sheet.hasTitle
			imageBorderColor = sheet.imageBorderColor
			imageBorderSize = sheet.imageBorderSize
			imageContentMode = sheet.imageContentMode
            imageHasBorder = sheet.imageHasBorder
			imagePathAWS = sheet.imagePathAWS
            imagePath = sheet.imagePath
            thumbnailPath = sheet.thumbnailPath
            tempSelectedImage = nil
		}
	}
	
    convenience init(sheetTitleImage: SheetTitleImageEntity, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: sheetTitleImage, context: context)
	}
	
}
