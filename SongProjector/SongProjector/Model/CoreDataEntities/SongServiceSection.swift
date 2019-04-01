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
	@NSManaged public var hasTags: NSSet?
	@NSManaged public var hasSongServiceSettings: SongServiceSettings?

	
	var tags: [Tag] {
		let unsortedTags = hasTags?.allObjects as? [Tag] ?? []
		return unsortedTags.sorted(by: { $0.title ?? "" > $1.title ?? "" })
	}
	
	enum CodingKeysSongServiceSection: String, CodingKey
	{
		case position
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
		CoreTag.managedObjectContext = mocBackground
		var oldTags: [Tag] = CoreTag.getEntities()
		var toKeep: [Tag] = []
		let tags = try container.decode([Tag].self, forKey: .tags)
		tags.forEach({
			if let index = oldTags.firstIndex(entity: $0) {
				toKeep.append(oldTags[index])
				$0.deleteBackground(false)
			} else {
				toKeep.append($0)
			}
		})
		hasTags = NSSet(array: toKeep)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSongServiceSection.self)
		try container.encode(position, forKey: .position)
		if let hasTags = hasTags?.allObjects as? [Tag] {
			try container.encode(hasTags, forKey: .tags)
		}
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
		
		let tags = Entity.getEntities { () -> [Tag] in
			return try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
		}
		hasTags = NSSet(array: tags)
		
		try super.initialization(decoder: decoder)
		
		tags.forEach({ $0.addToHasSongServiceSections(self) })
		
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
