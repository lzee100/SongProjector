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
            try container.encode((startDate as Date).intValue, forKey: .startDate)
		}
		if let endDate = endDate {
            try container.encode((endDate as Date).intValue, forKey: .endDate)
		}

		try super.encode(to: encoder)
	}

	
	
	// MARK: - Decodable
	required public convenience init(from decoder: Decoder) throws {
				
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysGoogleActivity.self)
        let endDateInt = try container.decodeIfPresent(Int64.self, forKey: .endDate) ?? Date().intValue
        endDate = Date(timeIntervalSince1970: TimeInterval(endDateInt / 1000)) as NSDate
        let startDateInt = try container.decodeIfPresent(Int64.self, forKey: .startDate) ?? Date().intValue
        startDate = Date(timeIntervalSince1970: TimeInterval(startDateInt / 1000)) as NSDate

		eventDescription = try container.decodeIfPresent(String.self, forKey: .eventDescription)

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
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {		super.getPropertiesFrom(entity: entity, context: context)
		if let activity = entity as? GoogleActivity {
			endDate = activity.endDate
			eventDescription = activity.eventDescription
			startDate = activity.startDate
		}
	}
	
    convenience init(activity: GoogleActivity, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: activity, context: context)
	}


}
