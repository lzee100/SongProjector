//
//  VSheetActivities.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VSheetActivities: VSheet, SheetMetaType {
	static let type: SheetType = .SheetActivities
		
	var hasGoogleActivity: [VGoogleActivity] = []
	

	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		try super.initialization(decoder: decoder)
		
	}
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetActivities
		copy.hasGoogleActivity = hasGoogleActivity
		return copy
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheetActivities = entity as? SheetActivitiesEntity {
			sheetActivities.hasGoogleActivity = NSSet(array: hasGoogleActivity.map({ $0.getManagedObject(context: context) }))
		}
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
		super.getPropertiesFrom(entity: entity, context: context)
		if let sheetActivities = entity as? SheetActivitiesEntity {
            hasGoogleActivity = (sheetActivities.hasGoogleActivity?.allObjects as? [GoogleActivity] ?? []).map({ VGoogleActivity(entity: $0, context: context) })
		}
	}
	
    convenience init(sheetActivities: SheetActivitiesEntity, context: NSManagedObjectContext) {
		self.init()
        getPropertiesFrom(entity: sheetActivities, context: context)
	}
	
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: SheetActivitiesEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SheetActivitiesEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

}


