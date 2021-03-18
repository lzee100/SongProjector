//
//  TagSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let TagSubmitter = TgSubmitter()

class TgSubmitter: Requester<VTag> {
    
    override var id: String {
        return "TagSubmitter"
    }
    override var path: String {
        return "tags"
    }
    
}
