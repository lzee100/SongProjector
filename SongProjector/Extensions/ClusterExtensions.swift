//
//  ClusterExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import CoreData


extension Cluster {
	
	// cluster has parent and has child
	// parent = normal songservice song as mp3 and sheets
	// child = piano alter call song as mp3 alone
		
    func isTypeSong(moc: NSManagedObjectContext = moc) -> Bool {
		return !hasSheets(moc: moc).contains(where: { $0.hasTheme?.isHidden == true })
	}
	
	func mergeSelfInto(cluster: Cluster) {
		cluster.deleteDate = nil
		cluster.title = title
		cluster.time = time
		cluster.title = title
	}
    
    func hasPianoSolo(moc: NSManagedObjectContext = moc) -> Bool {
		return hasInstruments(moc: moc).contains(where: { $0.type == .pianoSolo })
	}
	
    func hasMusic(moc: NSManagedObjectContext = moc) -> Bool {
        return hasInstruments(moc: moc).count > 0
	}
	
	override public func delete(_ save: Bool = true, context: NSManagedObjectContext, completion: ((Error?) -> Void)) {
        Entity.delete(entities: hasSheets(moc: context), save: save, context: context, completion: { error in
			if let error = error {
				completion(error)
			} else {
				Entity.delete(entities: hasInstruments(moc: context), save: save, context: context, completion: { error in
					if let error = error {
						completion(error)
					} else {
						super.delete(save, context: context, completion: completion)
					}
				})
			}
		})
	}
	
}
