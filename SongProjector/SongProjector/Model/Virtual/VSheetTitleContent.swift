//
//  VSheetTitleContent.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VSheetTitleContent: VSheet, SheetMetaType {
	
	static var type: SheetType = .SheetTitleContent
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VSheetTitleContent] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreSheetTitleContent.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreSheetTitleContent.getEntities().map({ VSheetTitleContent(sheet: $0) })
	}
	
	override class func single(with id: Int64?) -> VSheet? {
		if let id = id, let sheet = CoreSheetTitleContent.getEntitieWith(id: id) {
			return VSheetTitleContent(sheet: sheet)
		}
		return nil
	}
	
	
	var content: String?
	
	enum CodingKeysTitleContent:String, CodingKey
	{
		case content
	}
	
	
	
	// MARK: - Init
		
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysTitleContent.self)
		content = try container.decodeIfPresent(String.self, forKey: .content)
	}
	
	
	
	// MARK: - Encode
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTitleContent.self)
		try container.encode(content, forKey: .content)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
				
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysTitleContent.self)
		content = try container.decodeIfPresent(String.self, forKey: .content)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying

	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetTitleContent
		copy.content = content
		return copy
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let sheet = entity as? SheetTitleContentEntity {
			content = sheet.content
		}
	}
		
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheet = entity as? SheetTitleContentEntity {
			sheet.content = content
		}
	}
	
	convenience init(sheetTitleContent: SheetTitleContentEntity) {
		self.init()
		getPropertiesFrom(entity: sheetTitleContent)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		
		CoreSheetTitleContent.managedObjectContext = context
		if let storedEntity = CoreSheetTitleContent.getEntitieWith(id: id) {
			CoreSheetTitleContent.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreSheetTitleContent.managedObjectContext = context
			let entityDes = NSEntityDescription.entity(forEntityName: "SheetTitleContentEntity", in: context)
			let newEntity = NSManagedObject(entity: entityDes!, insertInto: context) as! SheetTitleContentEntity

			CoreSheetTitleContent.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
}
