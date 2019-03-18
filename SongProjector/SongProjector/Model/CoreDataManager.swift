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

let CoreEntity = CrEntity()
let CoreOrganization = CrOrganization()
let CoreContractLedger = CrContractLedger()
let CoreUser = CrUser()
let CoreRole = CrRole()
let CoreSheetActivities = CrSheetActivities()
let CoreGoogleActivities = CrGoogleAct()
let CoreTag = CrTag()
let CoreSheet = CrSheet()
let CoreSheetSplit = CrSplit()
let CoreSheetTitleContent = CrTitleContent()
let CoreSheetTitleImage = CrTitleImage()
let CoreSheetPastors = CrPastors()
let CoreSheetEmptySheet = CrEmptySheet()
let CoreCluster = CrCluster()
let CoreInstrument = CrInstrument()
let CoreBook = CrBook()
let CoreChapter = CrChapter()
let CoreVers = CrVers()
let CoreContract = CrContract()

// MARK: - Core Data stack

let Store = STR()

class STR {
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "SongProjector")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
}




var moc: NSManagedObjectContext = Store.persistentContainer.viewContext
var mocTemp: NSManagedObjectContext = {
	let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
	context.parent = moc
	return context
}()

var mocBackground: NSManagedObjectContext = {
	return Store.persistentContainer.newBackgroundContext()
}()


class CrEntity: CoreDataManager<Entity> { }
class CrOrganization: CoreDataManager<Organization> { }
class CrContractLedger: CoreDataManager<ContractLedger> { }
class CrRole: CoreDataManager<Role> { }
class CrUser: CoreDataManager<User> { }
class CrSheetActivities: CoreDataManager<SheetActivitiesEntity> { }
class CrGoogleAct: CoreDataManager<GoogleActivity> { }
class CrTag: CoreDataManager<Tag> { }
class CrSheet: CoreDataManager<Sheet> { }
class CrSplit: CoreDataManager<SheetSplitEntity> { }
class CrTitleContent: CoreDataManager<SheetTitleContentEntity> { }
class CrTitleImage: CoreDataManager<SheetTitleImageEntity> { }
class CrPastors: CoreDataManager<SheetPastorsEntity> { }
class CrEmptySheet: CoreDataManager<SheetEmptyEntity> { }
class CrCluster: CoreDataManager<Cluster> { }
class CrInstrument: CoreDataManager<Instrument> { }
class CrBook: CoreDataManager<Book> { }
class CrChapter: CoreDataManager<Chapter> { }
class CrVers: CoreDataManager<Vers> { }
class CrContract: CoreDataManager<Contract> { }

class CoreDataManager<T: NSManagedObject>: NSObject {

	var predicates: [NSPredicate] = []
	var getTemp = false
	private var sortDiscriptor: NSSortDescriptor?

	var managedObjectContext: NSManagedObjectContext = moc
	
	var entityName: String {
		return T.classForCoder().description().deletingPrefix("ChurchBeam.")
	}
	
	func createEntityNOTsave() -> T {
		let entityDes = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
		let entity = NSManagedObject(entity: entityDes!, insertInto: managedObjectContext) as! T
		
		if let entity = entity as? Entity {
			entity.id = Int64.random(in: 1...Int64.max)
			entity.isTemp = true
		}
		return entity
	}
	
	func getNewIDForEntityNOTsave() -> Int64 {
		return getNewId()
	}
	
	func createEntity(fireNotification: Bool = true) -> T {
		let entity = T(context: moc)
		
		// get ID
		sortDiscriptor = NSSortDescriptor(key: "id", ascending: false)
		
		if let entity = entity as? Entity {
			entity.id = getNewId()
		}
		let _ = saveContext(fireNotification: fireNotification) // raise ID
		clearSettings()
		return entity
	}
	
	@discardableResult
	func saveContext(fireNotification: Bool = true) -> Bool {
		do {
			try managedObjectContext.save()
			if managedObjectContext == mocBackground {
				try moc.save()
			}
			if fireNotification {
				Queues.main.async {
					NotificationCenter.default.post(name: NotificationNames.dataBaseDidChange, object:nil)
				}
			}
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
			let result = try moc.fetch(request)
			entity = result.first as? Entity
		} catch {
			print("Failed")
		}
		print(entity != nil ? entity!.id + 1 : Int64(0))
		clearSettings()
		return entity != nil ? entity!.id + 1 : Int64(0)
	}
	
	
	func getEntities(onlyTemp: Bool = false, onlyDeleted: Bool = false, skipFilter: Bool = false) -> [T] {
		var entities: [T] = []
		let request = NSFetchRequest<T>(entityName: entityName)

		if !skipFilter {
			if getTemp {
				predicates.append("isTemp", equals: true)
			} else if onlyDeleted {
				predicates.append("isTemp", equals: false)
				predicates.append(NSPredicate(format: "deleteDate != nil"))
			} else {
				predicates.append("isTemp", equals: false)
				predicates.append(NSPredicate(format: "deleteDate == nil"))
			}
		}
		
		let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
		request.predicate = andPredicate
		
		if let sortDiscriptor = sortDiscriptor {
			request.sortDescriptors = [sortDiscriptor]
		} else {
			sortDiscriptor = NSSortDescriptor(key: "createdAt", ascending: true)
			request.sortDescriptors = [sortDiscriptor!]
		}
		
		request.returnsObjectsAsFaults = false
		do {
			let result = try managedObjectContext.fetch(request)
			entities = result
		} catch {
			print("Failed")
		}
		clearSettings()
		return entities
	}
	
	func getEntitieWith(id: Int64) -> T? {
		predicates.append("id", equals: id)
		let entities = getEntities().first
		clearSettings()
		return entities
	}
	
	func getEntitiesWhere(attribute: String, has value: String) -> [T] {
		predicates.append(attribute, equals: value)
		let entities = getEntities()
		clearSettings()
		return entities
	}
	
	func setSortDescriptor(attributeName: String, ascending: Bool) {
		sortDiscriptor = NSSortDescriptor(key: attributeName, ascending: ascending)
	}
	
	private func clearSettings() {
		sortDiscriptor = nil
		predicates = []
		getTemp = false
		managedObjectContext = moc
	}
	
}
