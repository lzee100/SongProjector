//
//  SheetTitleImageEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

@objc(SheetTitleImageEntity)
public class SheetTitleImageEntity: Sheet, SheetMetaType {
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
	
	
	// MARK: - Init
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
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
		try container.encode(thumbnailPathAWS, forKey: .thumbnailPathAWS)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "SheetTitleImageEntity", in: managedObjectContext) else {
			fatalError("failed at SheetTitleImageEntity")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		//		try self.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeysTitleImage.self)
		hasTitle = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .hasTitle) ?? 0) as NSNumber)
		imageBorderColor = try container.decodeIfPresent(String.self, forKey: .imageBorderColor)
		content = try container.decodeIfPresent(String.self, forKey: .content)
		imageBorderSize = try container.decodeIfPresent(Int16.self, forKey: .imageBorderSize) ?? 0
		imageContentMode = try container.decodeIfPresent(Int16.self, forKey: .imageContentMode) ?? 0
		imageHasBorder = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .imageHasBorder) ?? 0) as NSNumber)
		thumbnailPathAWS = try container.decodeIfPresent(String.self, forKey: .thumbnailPathAWS)
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreSheetTitleImage.createEntityNOTsave()
		for key in self.entity.propertiesByName.keys {
			if key != "id" {
				let value: Any? = self.value(forKey: key)
				entity.setValue(value, forKey: key)
			}
		}
		deleteDate = Date() as NSDate
		return entity
	}
	
	

	
}
