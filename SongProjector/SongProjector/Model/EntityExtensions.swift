//
//  EntityExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation


extension Entity {
	
	@objc open func delete(_ save: Bool = true) {
		managedObjectContext?.delete(self)
		if save {
			do {
				try managedObjectContext?.save()
			} catch {
				print(error)
			}
		}
	}
	
	@objc open func deleteBackground(_ save: Bool = true) {
		mocBackground.delete(self)
		if save {
			do {
				try mocBackground.save()
			} catch {
				print(error)
			}
		}
	}
	
}
