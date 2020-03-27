//
//  UniversalClusterSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let UniversalClusterSubmitter = UversalClusterSubmitter()

class UversalClusterSubmitter: Requester<VCluster> {
	
	
	override var requesterId: String {
		return "UniversalClusterSubmitter"
	}
	
	override func createHeaderParameters() -> [String : String] {
		var headers = super.createHeaderParameters()
		headers["secret"] = UserDefaults.standard.string(forKey: secretKey)
		return headers
	}
	
	override var path: String {
		return "universalSongUpload"
	}
	
}
