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
	
	
	@NSManaged public var hasClusters: NSSet?
	@NSManaged public var hasSongServiceSections: NSSet?

	
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
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Tag", in: managedObjectContext) else {
			fatalError("failed at Tag")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
}

// MARK: Generated accessors for hasClusters
extension Tag {
	
	@objc(addHasClustersObject:)
	@NSManaged public func addToHasClusters(_ value: Cluster)
	
	@objc(removeHasClustersObject:)
	@NSManaged public func removeFromHasClusters(_ value: Cluster)
	
	@objc(addHasClusters:)
	@NSManaged public func addToHasClusters(_ values: NSSet)
	
	@objc(removeHasClusters:)
	@NSManaged public func removeFromHasClusters(_ values: NSSet)
	
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
