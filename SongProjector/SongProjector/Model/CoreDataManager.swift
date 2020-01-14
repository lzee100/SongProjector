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
let CoreTheme = CrTheme()
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
let CoreTag = CrTag()
let CoreTagId = CrTagId()
let CoreSongServiceSettings = CrSongServiceSettings()
let CoreSongServiceSection = CrSongServiceSection()

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




var moc: NSManagedObjectContext = {
	let context = Store.persistentContainer.viewContext
	context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
	return Store.persistentContainer.viewContext
}()

extension NSManagedObjectContext {
	
	static func saveForeground(vEntity: VEntity, success: @escaping (() -> Void), failure: @escaping  ((Error) -> Void)) {
		moc.perform {
			do {
				_ = vEntity.getManagedObject(context: moc)
				try moc.save()
				success()
			} catch {
				failure(error)
			}
		}
	}
	
}

var mocBackground: NSManagedObjectContext = {
	let context = Store.persistentContainer.newBackgroundContext()
	context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
	return context
}()


class CrEntity: CoreDataManager<Entity> { }
class CrOrganization: CoreDataManager<Organization> { }
class CrContractLedger: CoreDataManager<ContractLedger> { }
class CrRole: CoreDataManager<Role> { }
class CrUser: CoreDataManager<User> { }
class CrSheetActivities: CoreDataManager<SheetActivitiesEntity> { }
class CrGoogleAct: CoreDataManager<GoogleActivity> { }
class CrTheme: CoreDataManager<Theme> { }
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
class CrTag: CoreDataManager<Tag> { }
class CrTagId: CoreDataManager<TagId> { }
class CrSongServiceSettings: CoreDataManager<SongServiceSettings> { }
class CrSongServiceSection: CoreDataManager<SongServiceSection> { }

//enum EntityValues {
//	case entity
//	case cluster
//	case theme
//	case sheet
//	case sheetTitleContent
//	case
//
//	var entityType: NSManagedObject.Type {
//		switch self {
//		case .entity: return Entity.self
//		case .cluster: return Cluster.self
//		case .theme: return Theme.self
//		case .
//		}
//	}
//}

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
//		let id = getNewId()
//
//		if let entity = entity as? Entity {
//			entity.id = id
//			entity.isTemp = true
//		}
		
		return entity
	}
	
	func getNewIDForEntityNOTsave() -> Int64 {
		return getNewId()
	}
	
	func createEntity(fireNotification: Bool = true) -> T {
		let entity = T(context: managedObjectContext)
		
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
		request.includesPendingChanges = true
		
		request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
		
		request.returnsObjectsAsFaults = false
		do {
			let result = try managedObjectContext.fetch(request)
			entity = result.first as? Entity
		} catch {
			print("Failed")
		}
		print(entity != nil ? entity!.id + 1 : Int64(1))
		sortDiscriptor = nil
		predicates = []
		getTemp = false
		return entity != nil ? entity!.id + 1 : Int64(1)
	}
	
	func getEntities(skipDeleted: Bool = true) -> [T] {
		var entities: [T] = []
		let request = NSFetchRequest<T>(entityName: entityName)

		if skipDeleted {
			predicates.append(NSPredicate(format: "deleteDate == nil"))
		}
		
		let andPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
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
	
	func getUnfilteredEntities() -> [T] {
		var entities: [T] = []
		let request = NSFetchRequest<T>(entityName: entityName)
		
		let andPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
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
		clearSettings()
		predicates.append("id", equals: id)
		let entities = getEntities(skipDeleted: false).first
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
//		managedObjectContext = moc
	}
	
}
