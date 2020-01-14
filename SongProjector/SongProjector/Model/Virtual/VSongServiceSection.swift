//
//  VSongServiceSection.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VSongServiceSection: VEntity {
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VSongServiceSection] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreSongServiceSection.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreSongServiceSection.getEntities().map({ VSongServiceSection(songServiceSection: $0) })
	}
	
	class func single(with id: Int64?) -> VSongServiceSection? {
		if let id = id, let songServiceSection = CoreSongServiceSection.getEntitieWith(id: id) {
			return VSongServiceSection(songServiceSection: songServiceSection)
		}
		return nil
	}
	
	var position: Int16 = 0
	var numberOfSongs: Int16 = 0
	var tagIds: [NSNumber] = []
	var hasSongServiceSettings: VSongServiceSettings? = nil

	public var hasTags: [VTag] {
		return CoreTag.getEntities().filter({ tag in tagIds.contains(where: { NSNumber(value: tag.id) == $0 }) }).compactMap({ VTag(entity: $0) })
	}
	
	enum CodingKeysSongServiceSection: String, CodingKey
	{
		case position
		case numberOfSongs
		case tags
	}

	
	
	// MARK: - Init
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSection.self)
		position = try container.decode(Int16.self, forKey: .position)
		numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
		
		let tags = try container.decodeIfPresent([VTag].self, forKey: .tags) ?? []
		tagIds = tags.compactMap({ NSNumber(value: $0.id) })
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSongServiceSection.self)
		try container.encode(position, forKey: .position)
		try container.encode(numberOfSongs, forKey: .numberOfSongs)
		try container.encode(hasTags, forKey: .tags)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSection.self)
		position = try container.decode(Int16.self, forKey: .position)
		numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
		
		let tags = try container.decodeIfPresent([VTag].self, forKey: .tags) ?? []
		tagIds = tags.compactMap({ NSNumber(value: $0.id) })
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let songServiceSection = entity as? SongServiceSection {
			songServiceSection.position = position
			songServiceSection.numberOfSongs = numberOfSongs
			songServiceSection.tagIds = tagIds
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let songServiceSection = entity as? SongServiceSection {
			position = songServiceSection.position
			numberOfSongs = songServiceSection.numberOfSongs
			tagIds = songServiceSection.tagIds
		}
	}
	
	convenience init(songServiceSection: SongServiceSection) {
		self.init()
		getPropertiesFrom(entity: songServiceSection)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreSongServiceSection.managedObjectContext = context
		if let storedEntity = CoreSongServiceSection.getEntitieWith(id: id) {
			CoreSongServiceSection.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreSongServiceSection.managedObjectContext = context
			let newEntity = CoreSongServiceSection.createEntityNOTsave()
			CoreSongServiceSection.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}

	
}
