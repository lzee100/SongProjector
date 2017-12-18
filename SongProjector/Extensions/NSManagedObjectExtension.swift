//
//  NSManagedObjectExtension.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import CoreData

extension NSManagedObject {
	
	public static var name : String {
		
		return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
		
	}
	
	public func refresh(merging: Bool = true) {
		
		managedObjectContext?.refresh(self, mergeChanges: merging)
		
	}
	
}
