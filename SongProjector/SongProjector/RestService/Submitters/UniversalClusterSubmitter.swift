//
//  UniversalClusterSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let UniversalClusterSubmitter = UiversalClusterSubmitter()

class UiversalClusterSubmitter: CsterSubmitter {
    
    override var id: String {
        return "UniversalClusterSubmitter"
    }
    
    override var path: String {
        return "universalclusters"
    }
    
    override var uploadMusic: Bool {
        return true
    }
        
}
