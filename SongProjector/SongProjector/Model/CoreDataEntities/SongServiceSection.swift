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
	@NSManaged public var tagIds: String

    func hasTags(moc: NSManagedObjectContext) -> [Tag] {
        []
//        let ids = tagIds.split(separator: ",").compactMap({ String($0) })
//        let tags: [Tag] = ids.compactMap({ id in
//            let tag: Tag? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted, .get(id: id)])
//            return tag
//        })
//        return tags
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
