//
//  FetcherInfoBase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation

class RequesterInfoBase: RequesterInfo {
    
    var path: String {
        ""
    }
    var lastUpdatedAt: Int64? = nil
    
    func setLastUpdatedAt(_ objects: [EntityCodableType]) {
        objects.forEach { object in
            if let updatedAt = object.updatedAt {
                if let selfLastUpdatedAt = self.lastUpdatedAt, updatedAt.intValue > selfLastUpdatedAt {
                    lastUpdatedAt = (updatedAt as Date).intValue
                } else {
                    self.lastUpdatedAt = updatedAt.intValue
                }
            }
        }
    }
}
