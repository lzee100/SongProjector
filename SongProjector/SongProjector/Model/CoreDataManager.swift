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
    
    private let coreDataName = "SongProjector"
    private(set) var persistentContainer: NSPersistentContainer
    
    init() {
        let persistentContainer = NSPersistentContainer(name: coreDataName)
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.persistentContainer = persistentContainer
    }
    
    func setup() {
        // only for init to execute
    }
    
    func reset() {
        let storeContainer =
        persistentContainer.persistentStoreCoordinator

        do {
            for store in storeContainer.persistentStores {
                try storeContainer.destroyPersistentStore(
                    at: store.url!,
                    ofType: store.type,
                    options: nil
                )
            }
        } catch {
            print("could not delete core data container: \(error)")
        }

        persistentContainer = NSPersistentContainer(
            name: coreDataName
        )

        persistentContainer.loadPersistentStores {
            (store, error) in
            print(error)
        }
    }
}

var moc: NSManagedObjectContext {
	let context = Store.persistentContainer.viewContext
	context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
	return context
}

var newMOCBackground: NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.parent = moc
    context.automaticallyMergesChangesFromParent = true
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
    
    static var skipHidden: NSPredicate {
        return NSPredicate(format: "isHidden == false")
    }
    static func get(id: String) -> NSPredicate {
        return NSPredicate(format: "id = %@", id)
    }
}

enum Predicate {
    
    case skipDeleted
    case skipRootDeleted
    case skipHidden
    case get(id: String)
    case custom(format: String)
    case customWithValue(format: String, value: String)
    case compound(predicates: [Predicate], isOr: Bool)
    
    var predicate: NSPredicate {
        switch self {
        case .skipDeleted:
            return NSPredicate(format: "deleteDate == nil")
        case .skipRootDeleted:
            return NSPredicate(format: "rootDeleteDate == nil")
        case .skipHidden:
            return NSPredicate(format: "isHidden == false")
        case .get(id: let id):
            return NSPredicate(format: "id = %@", id)
        case .custom(let format):
            return NSPredicate(format: format)
        case .compound(predicates: let predicates, isOr: let isOr):
            if isOr {
                return NSCompoundPredicate(orPredicateWithSubpredicates: predicates.map { $0.predicate })
            } else {
                return NSCompoundPredicate(andPredicateWithSubpredicates: predicates.map { $0.predicate })
            }
        case .customWithValue(format: let format, value: let value):
            return NSPredicate(format: "\(format)", value)
        }
    }
}

enum SortDescriptor {
    
    case position(asc: Bool)
    case title(asc: Bool)
    case updatedAt(asc: Bool)
    case custom(key: String, ascending: Bool)

    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .position(asc: let asc):
            return NSSortDescriptor(key: "position", ascending: asc)
        case .title(asc: let asc):
            return NSSortDescriptor(key: "title", ascending: asc)
        case .updatedAt(asc: let asc):
            return NSSortDescriptor(key: "updatedAt", ascending: asc)
        case .custom(let key, let ascending):
            return NSSortDescriptor(key: key, ascending: ascending)
        }
    }
    
}
