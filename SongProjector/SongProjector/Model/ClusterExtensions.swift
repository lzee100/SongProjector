//
//  ClusterExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation


extension Cluster {
	
	// cluster has parent and has child
	// parent = normal songservice song as mp3 and sheets
	// child = piano alter call song as mp3 alone
	
	public var hasSheetsArray: [Sheet] {
		
		if let setHasSheets = hasSheets as? Set<Sheet> {
			return setHasSheets.sorted{ $0.position < $1.position }
		} else {
			return []
		}
	}
	
	public var isTypeSong: Bool {
		return !hasSheetsArray.contains(where: { $0.hasTag?.isHidden == true  })
	}
	
	public var tempVersion: Cluster {
		let tempCluster = CoreCluster.createEntityNOTsave()
		tempCluster.deleteDate = NSDate()
		tempCluster.title = title
		tempCluster.time = time
		tempCluster.title = title
		return tempCluster
	}
	
	func mergeSelfInto(cluster: Cluster) {
		cluster.deleteDate = nil
		cluster.title = title
		cluster.time = time
		cluster.title = title
		print("merged cluster")
	}
	
	public var hasInstrumentsArray: [Instrument] {
		
		if let setHasInstruments = hasInstruments as? Set<Instrument> {
			return Array(setHasInstruments)
		} else {
			return []
		}
	}
	
	public var hasPianoSolo: Bool {
		return hasInstrumentsArray.contains(where: { $0.type == .pianoSolo })
	}
	
	public var hasMusic: Bool {
		return (hasInstruments?.count ?? 0) > 0
	}

}
