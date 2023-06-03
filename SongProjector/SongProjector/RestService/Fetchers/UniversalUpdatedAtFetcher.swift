//
//  UniversalUpdatedAtFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let UniversalUpdatedAtFetcher = UiversalUpdatedAtFetcher()

class UiversalUpdatedAtFetcher: Requester<VUniversalUpdatedAt> {
    
    override var id: String {
        return "UniversalUpdatedAtFetcher"
    }
    override var path: String {
        return "universalupdatedat"
    }
    
    override var fetchAll: Bool {
        return false
    }
    
}
