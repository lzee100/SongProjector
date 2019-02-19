//
//  ClusterFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let ClusterFetcher = CstrFetcher()

class CstrFetcher: Requester<Cluster, SubmittedID> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "ClusterFetcher"
	}
	
	override var path: String {
		return "clusters"
	}
	
	override var requesterDependencies: [RequesterType] {
		return [TagFetcher]
	}
	
	override var coreDataManager: CoreDataManager<Cluster> {
		return CoreCluster
	}
	
	override var params: [String : Any] {
		CoreCluster.setSortDescriptor(attributeName: "updatedAt", ascending: false)
		let cluster = CoreCluster.getEntities().first
		var params = super.params
		if let date = cluster?.updatedAt {
			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
		}
		return params
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
}
