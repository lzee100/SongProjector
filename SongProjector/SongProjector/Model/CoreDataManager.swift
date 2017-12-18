//
//  CoreDataManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let CoreTag = CoreDataManager(nsManagedObject: Tag())
let CoreSheet = CoreDataManager(nsManagedObject: Sheet())
let CoreCluster = CoreDataManager(nsManagedObject: Cluster())

var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


class CoreDataManager<T: NSManagedObject>: NSObject {
	
	var predicates: [NSPredicate] = []
	private var sortDiscriptor: NSSortDescriptor?
	
	private let nsManagedObject: T
	
	init(nsManagedObject: T) {
		self.nsManagedObject = nsManagedObject
	}
	
	func createEntityNOTsave() -> T {
		let entityDes = NSEntityDescription.entity(forEntityName: nsManagedObject.classForCoder.description(), in: managedObjectContext)
		let entity = NSManagedObject(entity: entityDes!, insertInto: managedObjectContext) as! T
		
		// get ID
		sortDiscriptor = NSSortDescriptor(key: "id", ascending: false)
		
		if let first = getEntities().first as? Entity, let entity = entity as? Entity {
			entity.id = first.id + 1
		}
		
		return entity
	}
	
	func createEntity() -> T {
		let entityDes = NSEntityDescription.entity(forEntityName: nsManagedObject.classForCoder.description(), in: managedObjectContext)
		let entity = NSManagedObject(entity: entityDes!, insertInto: managedObjectContext) as! T
		
		// get ID
		sortDiscriptor = NSSortDescriptor(key: "id", ascending: false)
		
		if let first = getEntities().first as? Entity, let entity = entity as? Entity {
			entity.id = first.id + 1
			entity.createdAt = Date()
		}
		saveContext() // raise ID
		return entity
	}
	
	func saveContext() -> Bool {
		do {
			try managedObjectContext.save()
			return true
		} catch {
			print("Failed saving")
			return false
		}
	}
	
	func getEntities() -> [T] {
		var entities: [T] = []
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: nsManagedObject.classForCoder.description())
		
		for predicate in predicates {
			request.predicate = predicate
		}
		
		if let sortDiscriptor = sortDiscriptor {
			request.sortDescriptors = [sortDiscriptor]
		}
		
		request.returnsObjectsAsFaults = false
		do {
			let result = try managedObjectContext.fetch(request)
			entities = result as! [T]
		} catch {
			print("Failed")
		}
		predicates = []
		return entities
	}
	
	func setSortDescriptor(attributeName: String, ascending: Bool) {
		sortDiscriptor = NSSortDescriptor(key: attributeName, ascending: ascending)
	}
	
	func delete(entity: T) -> Bool {
		managedObjectContext.delete(entity)
		
		do {
			try managedObjectContext.save()
			print("saved!")
			return true
		} catch let error as NSError  {
			print("Could not save \(error), \(error.userInfo)")
			return false
		} catch {
			return false
		}
	}
	
}
