//
//  AdminFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let AdminFetcher = AminFetcher()

class AminFetcher: Requester<VAdmin> {
    
    override var id: String {
        return "AdminFetcher"
    }
    override var path: String {
        return "admin"
    }
    
    override var fetchAll: Bool {
        return false
    }
    
}
