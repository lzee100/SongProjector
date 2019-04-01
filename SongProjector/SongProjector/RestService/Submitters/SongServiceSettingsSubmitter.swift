//
//  SongServiceSettingsSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let SongServiceSettingsSubmitter: SngServiceSettingsSubmitter = {
	return SngServiceSettingsSubmitter()
}()

class SngServiceSettingsSubmitter: Requester<SongServiceSettings> {
	
	
	override var requesterId: String {
		return "SongServiceSettingsSubmitter"
	}
	
	override var path: String {
		return "songservicesettings"
	}
	
	override var coreDataManager: CoreDataManager<SongServiceSettings> {
		return CoreSongServiceSettings
	}
	
}
