//
//  VSheetSplit.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VSheetSplit: VSheet, SheetMetaType {
	
	static let type: SheetType = .SheetSplit
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VSheetSplit] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreSheetSplit.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreSheetSplit.getEntities().map({ VSheetSplit(sheet: $0) })
	}
	
	override class func single(with id: Int64?) -> VSheetSplit? {
		if let id = id, let sheet = CoreSheetSplit.getEntitieWith(id: id) {
			return VSheetSplit(sheet: sheet)
		}
		return nil
	}
	
	var textLeft: String?
	var textRight: String?

	
	enum CodingKeysSheetSplit:String,CodingKey
	{
		case textLeft = "contentLeft"
		case textRight = "contentRight"
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
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysSheetSplit.self)
		textLeft = try container.decodeIfPresent(String.self, forKey: .textLeft)
		textRight = try container.decodeIfPresent(String.self, forKey: .textRight)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetSplit
		copy.textLeft = textLeft
		copy.textRight = textRight
		return copy
	}
	

	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheet = entity as? SheetSplitEntity {
			sheet.textLeft = self.textLeft
			sheet.textRight = self.textRight
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let sheet = entity as? SheetSplitEntity {
			self.textLeft = sheet.textLeft
			self.textRight = sheet.textRight
		}
	}
	
	convenience init(sheet: SheetSplitEntity) {
		self.init()
		getPropertiesFrom(entity: sheet)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreSheetSplit.managedObjectContext = context
		if let storedEntity = CoreSheetSplit.getEntitieWith(id: id) {
			CoreSheetSplit.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreSheetSplit.managedObjectContext = context
			let newEntity = CoreSheetSplit.createEntity(fireNotification: false)
			CoreSheetSplit.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
}
