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


//// MARK: - Core Data stack
//
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

var newMOCBackground: NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.parent = moc
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    return context
}

extension NSPredicate {
    
    static var skipDeleted: NSPredicate {
        return NSPredicate(format: "deleteDate == nil")
    }
    static var skipRootDeleted: NSPredicate {
        return NSPredicate(format: "rootDeleteDate == nil")
    }
    static func get(id: String) -> NSPredicate {
        return NSPredicate(format: "id = %@", id)
    }
}

struct DataFetcher<T: Entity> {
    
    func getEntities(moc: NSManagedObjectContext, predicates: [NSPredicate] = [], sort: NSSortDescriptor? = nil) -> [T] {
        let Lock = NSRecursiveLock()
        var entityName: String {  return T.classForCoder().description().deletingPrefix("ChurchBeam.") }
        
        Lock.lock()
        
        var entities: [T] = []
        let request = NSFetchRequest<T>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        
        if let sortDiscriptor = sort {
            request.sortDescriptors = [sortDiscriptor]
        } else {
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        }
        
        do {
            let result = try moc.fetch(request)
            entities = result
        } catch {
            print("Failed")
            return []
        }
        
        Lock.unlock()
        
        return entities
    }
    
    func getEntity(moc: NSManagedObjectContext, predicates: [NSPredicate] = []) -> T? {
        let Lock = NSRecursiveLock()
        Lock.lock()
        var entityName: String {  return T.classForCoder().description().deletingPrefix("ChurchBeam.") }
        
        
        var entities: [T] = []
        let request = NSFetchRequest<T>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
                
        do {
            let result = try moc.fetch(request)
            entities = result
        } catch {
            print("Failed")
            return nil
        }
        
        Lock.unlock()
        
        return entities.first
        
    }
    
    func getLastUpdated(moc: NSManagedObjectContext) -> T? {
        let Lock = NSRecursiveLock()
        var entityName: String {  return T.classForCoder().description().deletingPrefix("ChurchBeam.") }
        
        Lock.lock()
        
        var entities: [T] = []
        let request = NSFetchRequest<T>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

        do {
            let result = try moc.fetch(request)
            entities = result
        } catch {
            print("Failed")
            return nil
        }
        
        Lock.unlock()
        
        return entities.first
        
    }
    
    func createEntity(moc: NSManagedObjectContext) -> T {
        var entityName: String {  return T.classForCoder().description().deletingPrefix("ChurchBeam.") }
        let entityDes = NSEntityDescription.entity(forEntityName: entityName, in: moc)
        let entity = NSManagedObject(entity: entityDes!, insertInto: moc) as! T
        entity.id = "ChurchBeam-\(UUID().uuidString)"
        return entity
    }



}
