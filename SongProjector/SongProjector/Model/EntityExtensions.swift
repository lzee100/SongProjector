//
//  EntityExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import CoreData

extension Entity {
		
	@objc open func delete(_ save: Bool = true, isBackground: Bool, completion: ((Error?) -> Void)) {
		if isBackground {
			mocBackground.delete(self)
			moc.delete(self)
			if save {
				mocBackground.performAndWait {
					do {
						try mocBackground.save()
						try moc.save()
						completion(nil)
					} catch {
						completion(error)
					}
				}
			}
		} else {
			moc.delete(self)
			if save {
				do {
					try moc.save()
					completion(nil)
				} catch {
					completion(error)
				}
			}
		}
	}
	
	static func delete<T: Entity>(entities: [T], save: Bool, isBackground: Bool, completion: ((Error?) -> Void)) {
		if let sheet = entities.first {
			var remainingEntities = entities
			remainingEntities.remove(at: 0)
			sheet.delete(save, isBackground: isBackground, completion: { error in
				if let error = error {
					completion(error)
				} else if remainingEntities.first != nil {
					delete(entities: remainingEntities, save: save, isBackground: isBackground, completion: completion)
				} else {
					completion(nil)
				}
			})
		} else {
			completion(nil)
		}
	}
	
}
