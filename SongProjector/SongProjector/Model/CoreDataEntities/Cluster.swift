//
//  Cluster.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class Cluster: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Cluster> {
		return NSFetchRequest<Cluster>(entityName: "Cluster")
	}
	
    @NSManaged public var root: String?
	@NSManaged public var isLoop: Bool
	@NSManaged public var position: Int16
	@NSManaged public var time: Double
	@NSManaged public var themeId: String
	@NSManaged public var lastShownAt: NSDate?
    @NSManaged public var instrumentIds: String?
    @NSManaged public var church: String?
    @NSManaged public var startTime: Double
    @NSManaged public var sheetIds: String
	@NSManaged var tagIds: String
    
    func hasTheme(moc: NSManagedObjectContext) -> Theme? {
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: themeId)])
        return theme
    }
    func hasTags(moc: NSManagedObjectContext) -> [Tag] {
        let tags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted])
        return tags.filter({ tag in splitTagIds.contains(tag.id) })
    }

    var splitTagIds: [String] {
        return tagIds.split(separator: ",").compactMap({ String($0) })
    }
	
    func hasSheets(moc: NSManagedObjectContext) -> [Sheet] {
        let splitSheetIds = sheetIds.split(separator: ",").compactMap({ String($0) })
        let sheets: [Sheet] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted])
        return sheets.filter({ sheet in splitSheetIds.contains(sheet.id) })
    }

    func hasInstruments(moc: NSManagedObjectContext) -> [Instrument] {
        let splitInstrumentIds = (instrumentIds ?? "").split(separator: ",").compactMap({ String($0) })
        let instruments: [Instrument] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted])
        return instruments.filter({ instrument in splitInstrumentIds.contains(instrument.id) })
    }
    
}
