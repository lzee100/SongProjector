//
//  ClusterExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation


extension Cluster {
	
	public var hasTagsArray: [Tag] {
		
		if let setHasTags = hasTags as? Set<Tag> {
			return setHasTags.sorted{ $0.position < $1.position }
		} else {
			return []
		}
	}
	
	

}
