//
//  SheetActivities.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData



class SheetActivitiesEntity: Sheet, SheetMetaType {
	static var type: SheetType {
		return .SheetActivities
	}
	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SheetActivitiesEntity> {
		return NSFetchRequest<SheetActivitiesEntity>(entityName: "SheetActivities")
	}
	
	@NSManaged public var hasGoogleActivity: NSSet?
	
	
	
	// MARK: - Init

	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
	}
	
	// encode and decode relation to GoogleActivity
	

	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "SheetActivitiesEntity", in: managedObjectContext) else {
			fatalError("failed at SheetActivitiesEntity")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		try super.initialization(decoder: decoder)
		
	}
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreGoogleActivities.createEntityNOTsave()
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


