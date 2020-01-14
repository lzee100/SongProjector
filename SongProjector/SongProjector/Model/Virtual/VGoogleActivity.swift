//
//  VGoogleActivity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VGoogleActivity: VEntity {
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VGoogleActivity] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreGoogleActivities.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreGoogleActivities.getEntities().map({ VGoogleActivity(activity: $0) })
	}
	
	class func single(with id: Int64?) -> VGoogleActivity? {
		if let id = id, let activity = CoreGoogleActivities.getEntitieWith(id: id) {
			return VGoogleActivity(activity: activity)
		}
		return nil
	}
	
	var endDate: NSDate? = nil
	var eventDescription: String? = nil
	var startDate: NSDate? = nil

	
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

	
	
	// MARK: - Decodable
	required public convenience init(from decoder: Decoder) throws {
				
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysGoogleActivity.self)
		endDate = try decodeDate(container: container, forKey: .endDate) ?? NSDate()
		eventDescription = try container.decodeIfPresent(String.self, forKey: .eventDescription)
		startDate = try decodeDate(container: container, forKey: .startDate) ?? NSDate()

		try super.initialization(decoder: decoder)
		
	}
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VGoogleActivity
		copy.endDate = endDate
		copy.eventDescription = eventDescription
		copy.startDate = startDate
		return copy
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let activity = entity as? GoogleActivity {
			activity.endDate = self.endDate
			activity.eventDescription = self.eventDescription
			activity.startDate = self.startDate
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let activity = entity as? GoogleActivity {
			endDate = activity.endDate
			eventDescription = activity.eventDescription
			startDate = activity.startDate
		}
	}
	
	convenience init(activity: GoogleActivity) {
		self.init()
		getPropertiesFrom(entity: activity)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreGoogleActivities.managedObjectContext = context
		if let storedEntity = CoreGoogleActivities.getEntitieWith(id: id) {
			CoreGoogleActivities.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreGoogleActivities.managedObjectContext = context
			let newEntity = CoreGoogleActivities.createEntityNOTsave()
			CoreGoogleActivities.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}


}
