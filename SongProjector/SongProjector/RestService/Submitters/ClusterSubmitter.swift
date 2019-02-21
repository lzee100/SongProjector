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

class CstrSubmitter: Requester<Cluster> {
	
	
	override var requesterId: String {
		return "ClusterSubmitter"
	}
	
	override var path: String {
		return "clusters/"
	}
	
	override var coreDataManager: CoreDataManager<Cluster> {
		return CoreCluster
	}
	
	
}
