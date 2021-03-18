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
		
	var position: Int16 = 0
	var numberOfSongs: Int16 = 0
	var tagIds: [String] = []
	var hasSongServiceSettings: VSongServiceSettings? = nil

    func hasTags(moc: NSManagedObjectContext) -> [VTag] {
        let persitentTags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted])
        return persitentTags.filter({ tag in tagIds.contains(tag.id) }).compactMap({ VTag(tag: $0, context: moc) })
    }
    	
	enum CodingKeysSongServiceSection: String, CodingKey
	{
        case id
		case position
		case numberOfSongs
		case tags
	}

	
	
	// MARK: - Init
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSection.self)
		position = try container.decode(Int16.self, forKey: .position)
		numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
        id = try container.decode(String.self, forKey: .id)
		let tags = try container.decodeIfPresent([VTag].self, forKey: .tags) ?? []
		tagIds = tags.compactMap({ $0.id })
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSongServiceSection.self)
        try container.encode(id, forKey: .id)
		try container.encode(position, forKey: .position)
		try container.encode(numberOfSongs, forKey: .numberOfSongs)
		try container.encode(hasTags(moc: newMOCBackground), forKey: .tags)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSection.self)
		position = try container.decode(Int16.self, forKey: .position)
		numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
        id = try container.decode(String.self, forKey: .id)

		let tags = try container.decodeIfPresent([VTag].self, forKey: .tags) ?? []
		tagIds = tags.compactMap({ $0.id })
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let songServiceSection = entity as? SongServiceSection {
			songServiceSection.position = position
			songServiceSection.numberOfSongs = numberOfSongs
            songServiceSection.tagIds = tagIds.joined(separator: ",")
            songServiceSection.id = id
		}
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let songServiceSection = entity as? SongServiceSection {
			position = songServiceSection.position
			numberOfSongs = songServiceSection.numberOfSongs
            tagIds = songServiceSection.tagIds.split(separator: ",").map({ String($0) })
            id = songServiceSection.id
		}
	}
	
    convenience init(songServiceSection: SongServiceSection, context: NSManagedObjectContext) {
		self.init()
        getPropertiesFrom(entity: songServiceSection, context: context)
	}
	
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: SongServiceSection = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SongServiceSection = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

	
}
