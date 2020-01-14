//
//  VSheetEmpty.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VSheetEmpty: VSheet, SheetMetaType {
	
	static var type: SheetType = .SheetEmpty

	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VSheetEmpty] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreSheetEmptySheet.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreSheetEmptySheet.getEntities().map({ VSheetEmpty(sheet: $0) })
	}
	
	override class func single(with id: Int64?) -> VSheetEmpty? {
		if let id = id, let sheet = CoreSheetEmptySheet.getEntitieWith(id: id) {
			return VSheetEmpty(sheet: sheet)
		}
		return nil
	}
	
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
		let copy = super.copy(with: zone) as! VSheetEmpty
		return copy
	}
	
	
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
	}
	
	convenience init(sheet: SheetEmptyEntity) {
		self.init()
		getPropertiesFrom(entity: sheet)
	}
	
	@discardableResult
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreSheetEmptySheet.managedObjectContext = context
		if let storedEntity = CoreSheetEmptySheet.getEntitieWith(id: id) {
			CoreSheetEmptySheet.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreSheetEmptySheet.managedObjectContext = context
			let newEntity = CoreSheetEmptySheet.createEntity(fireNotification: false)
			CoreSheetEmptySheet.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
}
