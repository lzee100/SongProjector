//
//  SheetTitleContentEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

@objc(SheetTitleContentEntity)
public class SheetTitleContentEntity: Sheet, SheetMetaType {
	static var type: SheetType {
		return .SheetTitleContent
	}
	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetTitleContentEntity> {
		return NSFetchRequest<SheetTitleContentEntity>(entityName: "SheetTitleContentEntity")
	}
	
	@NSManaged public var content: String?
	
	enum CodingKeysTitleContent:String,CodingKey
	{
		case content
	}
	
	
	
	// MARK: - Init
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysTitleContent.self)
		content = try container.decodeIfPresent(String.self, forKey: .content)
	}
	
	
	
	// MARK: - Encode
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTitleContent.self)
		try container.encode(content, forKey: .content)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "SheetTitleContentEntity", in: managedObjectContext) else {
			fatalError("failed at SheetTitleContentEntity")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysTitleContent.self)
		content = try container.decodeIfPresent(String.self, forKey: .content)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying

	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreSheetTitleContent.createEntityNOTsave()
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
