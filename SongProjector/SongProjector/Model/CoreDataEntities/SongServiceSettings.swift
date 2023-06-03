//
//  SongServiceSettings.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData


public class SongServiceSettings: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SongServiceSettings> {
		return NSFetchRequest<SongServiceSettings>(entityName: "SongServiceSettings")
	}
    @NSManaged public var sectionIds: String?

    func hasSections(moc: NSManagedObjectContext) -> [SongServiceSection] {
        []
//        let ids = sectionIds?.split(separator: ",").compactMap({ String($0) }) ?? []
//        let sections: [SongServiceSection] = ids.compactMap({ id in
//            let section: SongServiceSection? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: id)])
//            return section
//        })
//        return sections.sorted(by: { $0.position < $1.position })
    }
    
}

extension VSongServiceSettings {
	
	var isValid: Bool {
		var valid = true
		if sections.count == 0 {
			return false
		}
		for section in sections {
            if section.title == nil || section.hasTags(moc: moc).count == 0 || section.numberOfSongs == 0 {
				valid = false
				break
			}
		}
		return valid
	}
}
