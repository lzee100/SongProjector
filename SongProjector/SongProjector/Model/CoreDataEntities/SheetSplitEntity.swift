//
//  SheetSplitEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class SheetSplitEntity: Sheet, SheetMetaType {
	
	static var type: SheetType {
		return .SheetSplit
	}
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetSplitEntity> {
		return NSFetchRequest<SheetSplitEntity>(entityName: "SheetSplitEntity")
	}
	
	@NSManaged public var textLeft: String?
	@NSManaged public var textRight: String?

	
	enum CodingKeysSheetSplit:String,CodingKey
	{
		case textLeft = "contentLeft"
		case textRight = "contentRight"
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
		var container = encoder.container(keyedBy: CodingKeysSheetSplit.self)
		try container.encode(textLeft, forKey: .textLeft)
		try container.encode(textRight, forKey: .textRight)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "SheetSplitEntity", in: managedObjectContext) else {
			fatalError("failed at SheetSplitEntity")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysSheetSplit.self)
		textLeft = try container.decodeIfPresent(String.self, forKey: .textLeft)
		textRight = try container.decodeIfPresent(String.self, forKey: .textRight)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = VSheetSplit()
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
