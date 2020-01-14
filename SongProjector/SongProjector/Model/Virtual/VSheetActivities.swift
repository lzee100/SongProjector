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
	
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VSheetActivities] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreSheetActivities.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreSheetActivities.getEntities().map({ VSheetActivities(sheetActivities: $0) })
	}
	
	override class func single(with id: Int64?) -> VSheetActivities? {
		if let id = id, let sheetActivities = CoreSheetActivities.getEntitieWith(id: id) {
			return VSheetActivities(sheetActivities: sheetActivities)
		}
		return nil
	}
	
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
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let sheetActivities = entity as? SheetActivitiesEntity {
			hasGoogleActivity = (sheetActivities.hasGoogleActivity?.allObjects as? [GoogleActivity] ?? []).map({ VGoogleActivity(entity: $0) })
		}
	}
	
	convenience init(sheetActivities: SheetActivitiesEntity) {
		self.init()
		getPropertiesFrom(entity: sheetActivities)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreSheetActivities.managedObjectContext = context
		if let storedEntity = CoreSheetActivities.getEntitieWith(id: id) {
			CoreSheetActivities.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreSheetActivities.managedObjectContext = context
			let newEntity = CoreSheetActivities.createEntityNOTsave()
			CoreSheetActivities.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}

}


