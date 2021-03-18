//
//  SongServiceSettingsSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let SongServiceSettingsSubmitter = SngServiceSettingsSubmitter()

class SngServiceSettingsSubmitter: Requester<VSongServiceSettings> {
    
    override var id: String {
        return "SongServiceSettingsSubmitter"
    }
    override var path: String {
        return "songservicesettings"
    }
    
}
