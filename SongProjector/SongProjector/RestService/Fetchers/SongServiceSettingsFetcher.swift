//
//  SongServiceSettingsFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let SongServiceSettingsFetcher = SngServiceSettingsFetcher()

class SngServiceSettingsFetcher: Requester<VSongServiceSettings> {
    
    override var id: String {
        return "SongServiceSettingsFetcher"
    }
    override var path: String {
        return "songservicesettings"
    }
    
    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
        let songServiceSettings: SongServiceSettings? = DataFetcher().getLastUpdated(moc: moc)
        return songServiceSettings?.updatedAt as Date?
    }
        
}
