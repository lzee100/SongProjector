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

let CoreEntity = CoreDataManager(nsManagedObject: Entity())
let CoreSheetActivities = CoreDataManager(nsManagedObject: SheetActivities())
let CoreGoogleActivities = CoreDataManager(nsManagedObject: GoogleActivity())
let CoreTag = CoreDataManager(nsManagedObject: Tag())
let CoreSheet = CoreDataManager(nsManagedObject: Sheet())
let CoreSheetSplit = CoreDataManager(nsManagedObject: SheetSplitEntity())
let CoreSheetTitleContent = CoreDataManager(nsManagedObject: SheetTitleContentEntity())
let CoreSheetTitleImage = CoreDataManager(nsManagedObject: SheetTitleImageEntity())
let CoreSheetEmptySheet = CoreDataManager(nsManagedObject: SheetEmptyEntity())
let CoreCluster = CoreDataManager(nsManagedObject: Cluster())
let CoreSong = CoreDataManager(nsManagedObject: Song())
let CoreInstrument = CoreDataManager(nsManagedObject: Instrument())

let CoreBook = CoreDataManager(nsManagedObject: Book())
let CoreChapter = CoreDataManager(nsManagedObject: Chapter())
let CoreVers = CoreDataManager(nsManagedObject: Vers())


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
		
		if let entity = entity as? Entity {
			entity.id = getNewId()
		}
		
		return entity
	}
	
	func getNewIDForEntityNOTsave() -> Int64 {
		return getNewId()
	}
	
	func createEntity() -> T {
		let entityDes = NSEntityDescription.entity(forEntityName: nsManagedObject.classForCoder.description(), in: managedObjectContext)
		let entity = NSManagedObject(entity: entityDes!, insertInto: managedObjectContext) as! T
		
		// get ID
		sortDiscriptor = NSSortDescriptor(key: "id", ascending: false)
		
		if let entity = entity as? Entity {
			entity.id = getNewId()
			entity.createdAt = Date()
		}
		let _ = saveContext() // raise ID
		return entity
	}
	
	func saveContext() -> Bool {
		do {
			try managedObjectContext.save()
			NotificationCenter.default.post(name: NotificationNames.dataBaseDidChange, object:nil)
			return true
		} catch {
			print("Failed saving")
			return false
		}
	}
	
	private func getNewId() -> Int64 {
		var entity: Entity?
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.name)
		
		request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
		
		request.returnsObjectsAsFaults = false
		do {
			let result = try managedObjectContext.fetch(request)
			entity = result.first as? Entity
		} catch {
			print("Failed")
		}
		print(entity != nil ? entity!.id + 1 : Int64(0))
		return entity != nil ? entity!.id + 1 : Int64(0)
	}
	
	
	func getEntities() -> [T] {
		var entities: [T] = []
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: nsManagedObject.classForCoder.description())
		
		for predicate in predicates {
			request.predicate = predicate
		}
		
		if let sortDiscriptor = sortDiscriptor {
			request.sortDescriptors = [sortDiscriptor]
		} else {
			sortDiscriptor = NSSortDescriptor(key: "createdAt", ascending: true)
			request.sortDescriptors = [sortDiscriptor!]
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
	
	func getEntitieWith(id: Int64) -> T? {
		
		var entitie: T? = nil
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: nsManagedObject.classForCoder.description())
		
		predicates.append("id", equals: id)
		request.predicate = predicates.first
		
		if let sortDiscriptor = sortDiscriptor {
			request.sortDescriptors = [sortDiscriptor]
		}
		
		request.returnsObjectsAsFaults = false
		do {
			let result = try managedObjectContext.fetch(request).first
			if let result = result as? T {
				entitie = result
			}
		} catch {
			predicates = []
			return entitie
		}
		predicates = []
		return entitie
	}
	
	func setSortDescriptor(attributeName: String, ascending: Bool) {
		sortDiscriptor = NSSortDescriptor(key: attributeName, ascending: ascending)
	}
	
	func delete(entity: T) -> Bool {
		managedObjectContext.delete(entity)
		
		do {
			try managedObjectContext.save()
			NotificationCenter.default.post(name: NotificationNames.dataBaseDidChange, object:nil)
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
