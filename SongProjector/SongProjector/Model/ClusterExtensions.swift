//
//  ClusterExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation


extension Cluster {
	
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
	

}
