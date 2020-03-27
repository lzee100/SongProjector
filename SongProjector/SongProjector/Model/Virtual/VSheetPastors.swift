//
//  VSheetPastors.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VSheetPastors: VSheet, SheetMetaType {
	
	static var type: SheetType = .SheetPastors
	

	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VSheetPastors] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreSheetPastors.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreSheetPastors.getEntities().map({ VSheetPastors(sheet: $0) })
	}
	
	override class func single(with id: Int64?) -> VSheetPastors? {
		if let id = id, let sheet = CoreSheetPastors.getEntitieWith(id: id) {
			return VSheetPastors(sheet: sheet)
		}
		return nil
	}

	var content: String? = nil
	var imagePath: String? = nil
	var thumbnailPath: String? = nil
	var imagePathAWS: String? = nil
	var thumbnailPathAWS: String? = nil

	// not saving image path local
	enum CodingKeysPastors:String,CodingKey
	{
		case content
		case imagePath
		case thumbnailPath
		case imagePathAWS
	}
	
	
	
	// MARK: - Encodable

	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysPastors.self)
		try container.encode(content, forKey: .content)
		try container.encode(imagePath, forKey: .imagePath)
		try container.encode(thumbnailPath, forKey: .thumbnailPath)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		try super.encode(to: encoder)
	}
	

	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysPastors.self)

		content = try container.decodeIfPresent(String.self, forKey: .content)
		// FixMe: delete image paths local
		imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
		thumbnailPath = try container.decodeIfPresent(String.self, forKey: .thumbnailPath)
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetPastors
		copy.content = content
		copy.imagePath = imagePath
		copy.thumbnailPath = thumbnailPath
		copy.imagePathAWS = imagePathAWS
		copy.thumbnailPathAWS = thumbnailPathAWS
		return copy
	}
	
	
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheet = entity as? SheetPastorsEntity {
			sheet.content = self.content
			sheet.imagePath = self.imagePath
			sheet.thumbnailPath = self.thumbnailPath
			if sheet.imagePathAWS != imagePathAWS {
				sheet.imagePath = nil
				sheet.thumbnailPath = nil
			}
			sheet.imagePathAWS = self.imagePathAWS
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let sheet = entity as? SheetPastorsEntity {
			content = sheet.content
			imagePath = sheet.imagePath
			thumbnailPath = sheet.thumbnailPath
			imagePathAWS = sheet.imagePathAWS
		}
	}
	
	convenience init(sheet: SheetPastorsEntity) {
		self.init()
		getPropertiesFrom(entity: sheet)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreSheetPastors.managedObjectContext = context
		if let storedEntity = CoreSheetPastors.getEntitieWith(id: id) {
			CoreSheetPastors.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreSheetPastors.managedObjectContext = context
			let newEntity = CoreSheetPastors.createEntityNOTsave()
			CoreSheetPastors.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}

	

}
