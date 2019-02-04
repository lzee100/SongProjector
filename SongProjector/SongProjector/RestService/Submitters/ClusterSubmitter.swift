//
//  ClusterSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let ClusterSubmitter = CstrSubmitter()

class CstrSubmitter: Requester<Cluster, SubmittedID> {
	
	
	override var requesterId: String {
		return "ClusterSubmitter"
	}
	
	override var path: String {
		switch requestMethod {
		case .get, .post:
			return "clusters/"
		case .put, .delete:
			if let id = body?.id {
				return "clusters/\(id)"
			}
			return ""
		}
	}
	
	override var coreDataManager: CoreDataManager<Cluster> {
		return CoreCluster
	}
	
	override func saveLocal(entities: [Cluster]?) {
		
		super.saveLocal(entities: entities)
	}
	
	
}
