//
//  TagFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let TagFetcher = TgFetcher()

class TgFetcher: Requester<VTag> {
    
    override var id: String {
        return "TagFetcher"
    }
    override var path: String {
        return "tags"
    }
    
//    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
//        let tag: Tag? = DataFetcher().getLastUpdated(moc: moc)
//        return tag?.updatedAt as Date?
//    }

        
}
