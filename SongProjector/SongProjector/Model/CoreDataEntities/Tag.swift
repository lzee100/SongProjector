//
//  Tag.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData


public class Tag: Entity {
	
	@NSManaged public var position: Int16

	
	public var hasClusters: [Cluster] {
		return CoreCluster.getEntities().filter({ (cluster) -> Bool in
			return cluster.tagIds.contains(where: { $0 == NSNumber(value: cluster.id) })
		})
	}
	
	@NSManaged public var hasSongServiceSections: NSSet?

	enum CodingKeysTag: String, CodingKey {
		case position
	}
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
		return NSFetchRequest<Tag>(entityName: "Tag")
	}
	
	
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		try super.initialization(decoder: decoder)
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTag.self)
		try super.encode(to: encoder)
		try container.encode(position, forKey: .position)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Tag", in: managedObjectContext) else {
			fatalError("failed at Tag")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		let container = try decoder.container(keyedBy: CodingKeysTag.self)
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0

		try super.initialization(decoder: decoder)
		
	}
	
	
}

// MARK: Generated accessors for hasSongServiceSections
extension Tag {
	
	@objc(addHasSongServiceSectionsObject:)
	@NSManaged public func addToHasSongServiceSections(_ value: SongServiceSection)
	
	@objc(removeHasSongServiceSectionsObject:)
	@NSManaged public func removeFromHasSongServiceSections(_ value: SongServiceSection)
	
	@objc(addHasSongServiceSections:)
	@NSManaged public func addToHasSongServiceSections(_ values: NSSet)
	
	@objc(removeHasSongServiceSections:)
	@NSManaged public func removeFromHasSongServiceSections(_ values: NSSet)
	
}
