//
//  SongServicePlayDateSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let SongServicePlayDateSubmitter = SngServicePlayDateSubmitter()

class SngServicePlayDateSubmitter: Requester<VSongServicePlayDate>  {
    
    override var id: String {
        return "SongServicePlayDateSubmitter"
    }
    
    override var path: String {
        return "songserviceplaydate"
    }
        
}
