//
//  UniversalClusterUpdatedAtSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let UniversalClusterUpdatedAtSubmitter = UiversalClusterUpdatedAtSubmitter()

class UiversalClusterUpdatedAtSubmitter: Requester<VUniversalUpdatedAt>  {
    
    override var id: String {
        return "UniversalClusterUpdatedAtSubmitter"
    }
    
    override var path: String {
        return "universalupdatedat"
    }
        
}
