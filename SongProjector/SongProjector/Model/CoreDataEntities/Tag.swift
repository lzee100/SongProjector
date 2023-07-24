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
	
    @NSManaged public var positionInScheme: Int16
    @NSManaged public var isPinned: Bool
	@NSManaged public var position: Int16
    @NSManaged public var isDeletable: Bool
	@NSManaged public var hasSongServiceSections: NSSet?
    
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
		return NSFetchRequest<Tag>(entityName: "Tag")
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
