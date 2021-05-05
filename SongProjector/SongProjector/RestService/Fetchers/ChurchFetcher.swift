//
//  ChurchFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let ChurchFetcher = CurchFetcher()

class CurchFetcher: Requester<VChurch> {
    
    override var id: String {
        return "ChurchFetcher"
    }
    override var path: String {
        return "churches"
    }
    override var fetchUniversal: Bool {
        return true
    }
    
    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
        let church: Church? = DataFetcher().getLastUpdated(moc: moc)
        return church?.updatedAt as Date?
    }
    
}
