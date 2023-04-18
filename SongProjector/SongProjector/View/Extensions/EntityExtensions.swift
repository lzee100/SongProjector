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
		
    @objc open func delete(_ save: Bool = true, context: NSManagedObjectContext, completion: ((Error?) -> Void)) {
		if context != moc {
            context.delete(self)
			moc.delete(self)
			if save {
				context.performAndWait {
					do {
						try context.save()
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
	
    static func delete<T: Entity>(entities: [T], save: Bool, context: NSManagedObjectContext, completion: ((Error?) -> Void)) {
		if let sheet = entities.first {
			var remainingEntities = entities
			remainingEntities.remove(at: 0)
			sheet.delete(save, context: context, completion: { error in
				if let error = error {
					completion(error)
				} else if remainingEntities.first != nil {
					delete(entities: remainingEntities, save: save, context: context, completion: completion)
				} else {
					completion(nil)
				}
			})
		} else {
			completion(nil)
		}
	}
	
}
