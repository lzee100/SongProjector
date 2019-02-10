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
		moc.delete(self)
		if save {
			do {
				try moc.save()
			} catch {
				print(error)
			}
		}
	}
	
	@objc open func deleteBackground(_ save: Bool = true) {
		mocBackground.delete(self)
		if save {
			mocBackground.performAndWait {
				do {
					try mocBackground.save()
					try moc.save()
				} catch {
					print(error)
				}
			}
		}
	}
	
}
