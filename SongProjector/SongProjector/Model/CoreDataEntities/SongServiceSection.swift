//
//  SongServiceSection.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData


public class SongServiceSection: Entity {
	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SongServiceSection> {
		return NSFetchRequest<SongServiceSection>(entityName: "SongServiceSection")
	}
	
	@NSManaged public var position: Int16
	@NSManaged public var numberOfSongs: Int16
	@NSManaged var tagIds: [NSNumber]
	@NSManaged public var hasSongServiceSettings: SongServiceSettings?

	public var hasTags: [Tag] {
		return CoreTag.getEntities().filter({ tag in tagIds.contains(where: { NSNumber(value: tag.id) == $0 }) })
	}
	
	enum CodingKeysSongServiceSection: String, CodingKey
	{
		case position
		case numberOfSongs
		case tags
	}

	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSection.self)
		position = try container.decode(Int16.self, forKey: .position)
		numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
		
		let tags = Entity.getEntities(decodeNew: { () -> [Tag] in
			return try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
		})
		tagIds = tags.compactMap({ NSNumber(value: $0.id) })
		
		try super.initialization(decoder: decoder)
		
		tags.forEach({ $0.addToHasSongServiceSections(self) })

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
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "SongServiceSection", in: managedObjectContext) else {
			fatalError("failed at SongServiceSection")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSection.self)
		position = try container.decode(Int16.self, forKey: .position)
		numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
		
		let tags = Entity.getEntities { () -> [Tag] in
			return try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
		}
		tagIds = tags.compactMap({ NSNumber(value: $0.id) })
		
		try super.initialization(decoder: decoder)
		
		tags.forEach({
			if let sections = $0.hasSongServiceSections?.allObjects as? [SongServiceSection], !sections.contains(self) {
				$0.addToHasSongServiceSections(self)
			}
		})
	}
	
	
	
	
}

// MARK: Generated accessors for hasTags
extension SongServiceSection {
	
	@objc(addHasTagsObject:)
	@NSManaged public func addToHasTags(_ value: Tag)
	
	@objc(removeHasTagsObject:)
	@NSManaged public func removeFromHasTags(_ value: Tag)
	
	@objc(addHasTags:)
	@NSManaged public func addToHasTags(_ values: NSSet)
	
	@objc(removeHasTags:)
	@NSManaged public func removeFromHasTags(_ values: NSSet)
	
}
