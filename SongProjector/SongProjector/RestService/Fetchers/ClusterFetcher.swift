//
//  ClusterFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let ClusterFetcher = CstrFetcher()

class CstrFetcher: Requester<VCluster> {
	
	override var requesterId: String {
		return "ClusterFetcher"
	}
	
	override var path: String {
		return "clusters"
	}
	
	override var dependencies: [RequesterDependency] {
		return [ThemeFetcher, TagFetcher]
	}
	
	override var params: [String : Any] {
		var params = super.params
//		if let date = VCluster.list(sortOn: "updatedAt", ascending: false).first?.updatedAt {
//			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
//		}
		return params
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else {
			print("cluster blocked")
			return
			
		}
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
}
