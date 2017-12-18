//
//  AppDelegate.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var externalDisplayWindow: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		addDataBaseObjects()
		setupAirPlay()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
	}

	// MARK: - Core Data stack

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

	private func addDataBaseObjects() {
		CoreTag.predicates.append("title", equals: "Player")
		var tags = CoreTag.getEntities()
		if tags.count == 0 {
			let tag = CoreTag.createEntity()
			tag.title = "Player"
			let _ = CoreTag.saveContext()
		}
		CoreTag.predicates.append("title", equals: "Songs")
		tags = CoreTag.getEntities()
		if tags.count == 0 {
			let tag = CoreTag.createEntity()
			tag.title = "Songs"
			let _ = CoreTag.saveContext()
		}
		CoreTag.predicates.append("title", equals: "Security")
		tags = CoreTag.getEntities()
		if tags.count == 0 {
			let tag = CoreTag.createEntity()
			tag.title = "Security"
			let _ = CoreTag.saveContext()
		}
	}
	
	private func setupAirPlay() {
		
		checkForExternalDisplay()
		
		NotificationCenter.default.addObserver(
			forName: Notification.Name.UIScreenDidConnect,
			object: nil,
			queue: nil,
			using: displayConnected)
		
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.UIScreenDidDisconnect,
			object: nil,
			queue: nil,
			using: displayDisconnected
		)
		
	}
	
	func displayConnected(notification: Notification) {
		checkForExternalDisplay()
	}
	
	func checkForExternalDisplay() {
		guard let screen = UIScreen.screens.last
			else { return }
		
		if externalDisplayWindow == nil {
			externalDisplayWindow = UIWindow(
				frame: screen.bounds
			)
			externalDisplayWindow?.screen = screen
			NotificationCenter.default.post(name: Notification.Name("externalScreenIsActive"), object: nil, userInfo: ["screen": screen])
		}
	}
	
	func displayDisconnected(notification: Notification) {
		externalDisplayWindow?.isHidden = true
		externalDisplayWindow = nil
	}

}

