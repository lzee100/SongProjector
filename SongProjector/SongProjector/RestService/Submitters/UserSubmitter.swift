//
// UserSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let UserSubmitter = UerSubmitter()

class UerSubmitter: Requester<VUser> {
    
    override var id: String {
        return "UserSubmitter"
    }
    override var path: String {
        return "users"
    }
    
    override func submit(_ entity: [VUser], requestMethod: RequestMethod) {
        super.submit(entity, requestMethod: requestMethod)
    }
}
