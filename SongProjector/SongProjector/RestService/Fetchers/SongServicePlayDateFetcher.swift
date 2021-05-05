//
//  SongServicePlayDateFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let SongServicePlayDateFetcher = SngServicePlayDateFetcher()

class SngServicePlayDateFetcher: Requester<VSongServicePlayDate> {
    
    override var id: String {
        return "SongServicePlayDateFetcher"
    }
    override var path: String {
        return "songserviceplaydate"
    }
    
    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
        let playDate: SongServicePlayDate? = DataFetcher().getLastUpdated(moc: moc)
        return playDate?.updatedAt as Date?
    }

    
}
