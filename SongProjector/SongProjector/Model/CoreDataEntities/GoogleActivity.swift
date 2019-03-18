//
//  GoogleActivity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//


import Foundation
import CoreData

public class GoogleActivity: Entity {	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<GoogleActivity> {
		return NSFetchRequest<GoogleActivity>(entityName: "GoogleActivity")
	}
	
	@NSManaged public var endDate: NSDate?
	@NSManaged public var eventDescription: String?
	@NSManaged public var startDate: NSDate?

	
	enum CodingKeysGoogleActivity:String,CodingKey
	{
		case eventDescription
		case startDate
		case endDate

	}
	
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysGoogleActivity.self)
		
		try container.encode(eventDescription, forKey: .eventDescription)
		
		if let startDate = startDate {
			let startDateString = GlobalDateFormatter.localToUTC(date: startDate as Date)
			try container.encode(startDateString, forKey: .startDate)
		}
		if let endDate = endDate {
			let endDateString = GlobalDateFormatter.localToUTC(date: endDate as Date)
			try container.encode(endDateString, forKey: .endDate)
		}

		try super.encode(to: encoder)
	}
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
	}
	// MARK: - Decodable
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "GoogleActivity", in: managedObjectContext) else {
			fatalError("failed at GoogleActivity")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		//		try self.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeysGoogleActivity.self)
		endDate = try decodeDate(container: container, forKey: .endDate) ?? NSDate()
		eventDescription = try container.decodeIfPresent(String.self, forKey: .eventDescription)
		startDate = try decodeDate(container: container, forKey: .startDate) ?? NSDate()

		try super.initialization(decoder: decoder)
		
	}
	
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
