//
//  VSheetSplit.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VSheetSplit: VSheet, VSheetMetaType {
	
	static let type: SheetType = .SheetSplit
	
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
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let sheet = entity as? SheetSplitEntity {
			self.textLeft = sheet.textLeft
			self.textRight = sheet.textRight
		}
	}
	
	convenience init(sheet: SheetSplitEntity, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: sheet, context: context)
	}
	
//    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
//        if let entity: SheetSplitEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        } else {
//            let entity: SheetSplitEntity = DataFetcher().createEntity(moc: context)
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        }
//    }
}
