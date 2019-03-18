//
//  SheetPastorsEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class SheetPastorsEntity: Sheet, SheetMetaType {
	
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

	// not saving image path local 
	enum CodingKeysPastors:String,CodingKey
	{
		case content
		case imagePathAWS
		case thumbnailPathAWS
	}
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
	}
	
	
	
	// MARK: - Encodable

	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysPastors.self)
		try container.encode(content, forKey: .content)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		try container.encode(thumbnailPathAWS, forKey: .thumbnailPathAWS)
		try super.encode(to: encoder)
	}
	

	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "SheetPastorsEntity", in: managedObjectContext) else {
			fatalError("failed at SheetPastorsEntity")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		//		try self.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeysPastors.self)

		content = try container.decodeIfPresent(String.self, forKey: .content)
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		thumbnailPathAWS = try container.decodeIfPresent(String.self, forKey: .thumbnailPathAWS)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreSheetPastors.createEntityNOTsave()
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
