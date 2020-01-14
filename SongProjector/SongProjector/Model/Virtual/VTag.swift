//
//  VTag.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VTag: VEntity {
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VTag] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreTag.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreTag.getEntities().map({ VTag(tag: $0) })
	}
	
	class func single(with id: Int64?) -> VTag? {
		if let id = id, let tag = CoreTag.getEntitieWith(id: id) {
			return VTag(tag: tag)
		}
		return nil
	}

	
	var position: Int16 = 0

	
	public var hasClusters: [VCluster] {
		return CoreCluster.getEntities().filter({ (cluster) -> Bool in
			return cluster.tagIds.contains(where: { $0 == NSNumber(value: cluster.id) })
			}).map({ VCluster(cluster: $0) })
	}
	
	var hasSongServiceSections: [VSongServiceSection] = []

	enum CodingKeysTag: String, CodingKey {
		case position
	}
		
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTag.self)
		try container.encode(position, forKey: .position)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysTag.self)
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0

		try super.initialization(decoder: decoder)
		
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let tag = entity as? Tag {
			tag.position = position
		}

	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let tag = entity as? Tag {
			position = tag.position
		}
	}
	
	convenience init(tag: Tag) {
		self.init()
		getPropertiesFrom(entity: tag)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreTag.managedObjectContext = context
		if let storedEntity = CoreTag.getEntitieWith(id: id) {
			CoreTag.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreTag.managedObjectContext = context
			let newEntity = CoreTag.createEntityNOTsave()
			CoreTag.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
}
