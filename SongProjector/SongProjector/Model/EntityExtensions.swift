//
//  EntityExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation


extension Entity {
	
	@objc open func delete() {
		_ = CoreEntity.delete(entity: self)
		_ = CoreEntity.saveContext()
	}
	
}
