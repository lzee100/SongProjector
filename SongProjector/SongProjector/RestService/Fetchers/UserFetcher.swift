//
//  UserFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let UserFetcher = UerFetcher()

class UerFetcher: Requester<VUser> {
    
    override var id: String {
        return "UserFetcher"
    }
    override var path: String {
        return "users"
    }
    
    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
        let user: User? = DataFetcher().getLastUpdated(moc: moc)
        return user?.updatedAt as Date?
    }
    
}
