
//
//  AppDelegate.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import CoreData
import Photos
import GGLSignIn
import UIKit
import Google
import GoogleSignIn
import AWSMobileClient
import AWSGoogleSignIn
import AWSAuthCore


var canUsePhotos: Bool {

	get {
		let defaults = UserDefaults.standard
		return defaults.bool(forKey: "canUsePhotos")
	}
	set {
		let defaults = UserDefaults.standard
		defaults.set(newValue, forKey: "canUsePhotos")
	}
}

var externalDisplayWindow: UIWindow? {
	didSet {
		let defaults = UserDefaults.standard
		defaults.set(externalDisplayWindow?.frame.width, forKey: "lastScreenWidth")
		defaults.set(externalDisplayWindow?.frame.height, forKey: "lastScreenHeight")
	}
}

var externalDisplayWindowRatio: CGFloat {
	let defaults = UserDefaults.standard
	if defaults.float(forKey: "lastScreenHeight") != 0 && defaults.float(forKey: "lastScreenWidth") != 0 {
		return CGFloat(defaults.float(forKey: "lastScreenHeight")) / CGFloat(defaults.float(forKey: "lastScreenWidth"))
	} else {
		return 9/16
	}
}

var externalDisplayWindowRatioHeightWidth: CGFloat {
	let defaults = UserDefaults.standard
	if defaults.float(forKey: "lastScreenHeight") != 0 && defaults.float(forKey: "lastScreenWidth") != 0 {
		return CGFloat(defaults.float(forKey: "lastScreenWidth")) / CGFloat(defaults.float(forKey: "lastScreenHeight"))
	} else {
		return 16/9
	}
}

var externalDisplayWindowHeight: CGFloat {
	let defaults = UserDefaults.standard
	if defaults.float(forKey: "lastScreenHeight") != 0 {
		return CGFloat(defaults.float(forKey: "lastScreenHeight"))
	} else {
		return 1080
	}
}

var externalDisplayWindowWidth: CGFloat {
	let defaults = UserDefaults.standard
	if defaults.float(forKey: "lastScreenWidth") != 0 {
		return CGFloat(defaults.float(forKey: "lastScreenWidth"))
	} else {
		return 1920
	}
}

func getSizeWith(height: CGFloat? = nil, width: CGFloat? = nil) -> CGSize {
	if let height = height {
		return CGSize(width: height * externalDisplayWindowRatioHeightWidth, height: height)
	} else if let width = width {
		return CGSize(width: width, height: width / externalDisplayWindowRatioHeightWidth)
	} else {
		return CGSize(width: 10, height: 10)
	}
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	

	var window: UIWindow?
	//Used for checking whether Push Notification is enabled in Amazon Pinpoint
	static let remoteNotificationKey = "RemoteNotification"
	var isInitialized: Bool = false

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		setupAndCheckDatabase()
		setupAirPlay()
		application.statusBarStyle = .lightContent
		AppTheme.setup()
		if PHPhotoLibrary.authorizationStatus() == .notDetermined {
			PHPhotoLibrary.requestAuthorization({ (status) in
				if status == PHAuthorizationStatus.authorized {
					canUsePhotos = true
				} else {
					canUsePhotos = false
				}
			})
		}
		
//		AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
//		AWSSignInManager.sharedInstance().register(signInProvider: AWSGoogleSignInProvider.sharedInstance())
//		let didFinishLaunching = AWSSignInManager.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
//
//		if (!isInitialized) {
//			AWSSignInManager.sharedInstance().resumeSession(completionHandler: { (result: Any?, error: Error?) in
//				print("Result: \(result) \n Error:\(error)")
//			})
//			isInitialized = true
//		}
//
//
//
//		// Initialize the Amazon Cognito credentials provider
//
//		let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUWest2,
//																identityPoolId:"eu-west-2:e0602561-4fd7-4f01-94f2-790acd22d640")
//		let configuration = AWSServiceConfiguration(region:.EUWest2, credentialsProvider: credentialsProvider)
//
//		AWSServiceManager.default().defaultServiceConfiguration = configuration
//
//		AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
//		AWSDDLog.sharedInstance.logLevel = .info
//		return AWSMobileClient.sharedInstance().interceptApplication(
//			application, didFinishLaunchingWithOptions:
//			launchOptions)
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
	
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		// print("application application: \(application.description), openURL: \(url.absoluteURL), sourceApplication: \(sourceApplication)")
		
		AWSMobileClient.sharedInstance().interceptApplication(
			application, open: url,
			sourceApplication: sourceApplication,
			annotation: annotation)
		
		AWSSignInManager.sharedInstance().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
		isInitialized = true
		
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		
		return AWSMobileClient.sharedInstance().interceptApplication(
			app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation]!)
		
		return GIDSignIn.sharedInstance().handle(url,
													sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
													annotation: options[UIApplicationOpenURLOptionsKey.annotation])
	}

	private func setupAndCheckDatabase() {
		
		// remove temporary sheets or tags that were created but session got lost (app terminated durring configuration process)
		CoreEntity.getTemp = true
		var entities = CoreEntity.getEntities()
		for entity in entities{
			_ = CoreEntity.delete(entity: entity)
		}
		CoreEntity.getTemp = false
		
		let predicate = NSPredicate(format: "title == %@", 0)
		CoreEntity.predicates.append(and: [predicate])
		entities = CoreEntity.getEntities()
		for entity in entities {
			_ = CoreEntity.delete(entity: entity)
		}
	
		CoreTheme.predicates.append("title", equals: "Player")
		var tags = CoreTheme.getEntities()
		if tags.count == 0 {
			let tag = CoreTheme.createEntity()
			tag.title = "Player"
			tag.deletedAt = Date()
			let _ = CoreTheme.saveContext()
		}
		CoreTheme.predicates.append("title", equals: "Songs")
		tags = CoreTheme.getEntities()
		if tags.count == 0 {
			let tag = CoreTheme.createEntity()
			tag.title = "Songs"
			tag.deletedAt = Date()
			let _ = CoreTheme.saveContext()
		}
		CoreTheme.predicates.append("title", equals: "Security")
		tags = CoreTheme.getEntities()
		if tags.count == 0 {
			let tag = CoreTheme.createEntity()
			tag.deletedAt = Date()
			tag.title = "Security"
			let _ = CoreTheme.saveContext()
		}
		
		CoreInstrument.predicates.append("resourcePath", equals: "kort")
		let kort = CoreInstrument.getEntities()
		if kort.count == 0 {
			let kort = CoreInstrument.createEntity()
			kort.type = .piano
			kort.resourcePath = "kort"
			kort.isLoop = false
			kort.deletedAt = Date()
			kort.title = "kort"
		}

		
		CoreInstrument.predicates.append("resourcePath", equals: "LordLoop")
		let lord = CoreInstrument.getEntities()
		if lord.count == 0 {
			let lord = CoreInstrument.createEntity()
			lord.type = .pianoSolo
			lord.resourcePath = "LordLoop"
			lord.isLoop = true
			lord.deletedAt = Date()
			lord.title = "LordLoop"
		}
		
		CoreInstrument.predicates.append("resourcePath", equals: "LordSong")
		let lordSong = CoreInstrument.getEntities()
		if lordSong.count == 0 {
			let lordSong = CoreInstrument.createEntity()
			lordSong.type = .piano
			lordSong.resourcePath = "LordSong"
			lordSong.isLoop = true
			lordSong.deletedAt = Date()
			lordSong.title = "LordSong"
		}
		
		CoreInstrument.predicates.append("typeString", equals: "Keyboard")
		let pianos = CoreInstrument.getEntities()
		if pianos.count == 0 {
			let piano = CoreInstrument.createEntity()
			piano.type = .piano
			piano.resourcePath = "Keyboard"
			piano.title = "piano"
			piano.deletedAt = Date()
		}
		
		CoreInstrument.predicates.append("typeString", equals: "Guitar")
		let guitars = CoreInstrument.getEntities()
		if guitars.count == 0 {
			let guitar = CoreInstrument.createEntity()
			guitar.type = .guitar
			guitar.resourcePath = "Guitar"
			guitar.title = "guitar"
			guitar.deletedAt = Date()
		}
		
		CoreInstrument.predicates.append("typeString", equals: "Bass")
		let bassGuitars = CoreInstrument.getEntities()
		if bassGuitars.count == 0 {
			let bassGuitar = CoreInstrument.createEntity()
			bassGuitar.type = .bassGuitar
			bassGuitar.resourcePath = "Bass"
			bassGuitar.title = "bassGuitar"
			bassGuitar.deletedAt = Date()
		}
		
		CoreInstrument.predicates.append("typeString", equals: "Drums")
		let drums = CoreInstrument.getEntities()
		if drums.count == 0 {
			let drum = CoreInstrument.createEntity()
			drum.type = .drums
			drum.resourcePath = "Drums"
			drum.title = "drums"
			drum.deletedAt = Date()
		}
		
		let _ = CoreInstrument.saveContext()

		CoreCluster.predicates.append("title", equals: "Ik zing vol blijdschap en lach")
		if CoreCluster.getEntities().count == 0 {
			let ikZing = CoreCluster.createEntity()
			ikZing.title = "Ik zing vol blijdschap en lach"
			ikZing.deletedAt = Date()

			CoreTheme.predicates.append("title", equals: "Security")
			let tag = CoreTheme.getEntities().first
			
			ikZing.hasTag = tag
			
			let sheet1 = CoreSheetTitleContent.createEntity()
			sheet1.title = "Ik zing vol blijdschap en lach"
			sheet1.lyrics = """
			Ik zing vol blijdschap en lach
			Want de vreugde van God is mijn kracht
			Wij buigen neer aanbidden Hem nu,
			hoe groot en machtig is Hij
			Iedereen zingt, iedereen zingt
			"""
			sheet1.time = 36
			sheet1.hasCluster = ikZing
			sheet1.position = 0
			sheet1.deletedAt = Date()

			let sheet2 = CoreSheetTitleContent.createEntity()
			sheet2.title = "Heilig is de heer"
			sheet2.lyrics = """
			Heilig is de Heer, God almachtig
			de aarde is vol van Zijn glorie (2x)
			"""
			sheet2.time = 26.80
			sheet2.hasCluster = ikZing
			sheet2.position = 1
			sheet2.deletedAt = Date()

			let sheet3 = CoreSheetTitleContent.createEntity()
			sheet3.title = "Ik zing vol blijdschap en lach"
			sheet3.lyrics = """
			Ik zing vol blijdschap en lach
			Want de vreugde van God is mijn kracht
			Wij buigen neer aanbidden Hem nu,
			hoe groot en machtig is Hij
			Iedereen zingt, iedereen zingt
			"""
			sheet3.time = 29.70
			sheet3.hasCluster = ikZing
			sheet3.position = 2
			sheet3.deletedAt = Date()

			
			let sheet4 = CoreSheetTitleContent.createEntity()
			sheet4.title = "Heilig is de heer"
			sheet4.lyrics = """
			Heilig is de Heer, God almachtig
			de aarde is vol van Zijn glorie (2x)
			"""
			sheet4.time = 27
			sheet4.hasCluster = ikZing
			sheet4.position = 3
			sheet4.deletedAt = Date()

			let sheet5 = CoreSheetTitleContent.createEntity()
			sheet5.title = "Hij komt terug"
			sheet5.lyrics = """
			Hij komt terug, Hij heeft het beloofd
			voor iedereen die in Hem geloofd (2X)
			"""
			sheet5.time = 24.10
			sheet5.hasCluster = ikZing
			sheet5.position = 4
			sheet5.deletedAt = Date()

			
			let sheet6 = CoreSheetTitleContent.createEntity()
			sheet6.title = "Iedereen zingt"
			sheet6.lyrics = """
			Iedereen zingt, iedereen zingt
			"""
			sheet6.time = 10
			sheet6.hasCluster = ikZing
			sheet6.position = 5
			sheet6.deletedAt = Date()
			
			let sheet7 = CoreSheetTitleContent.createEntity()
			sheet7.title = "Heilig is de heer"
			sheet7.lyrics = """
			Heilig is de Heer, God almachtig
			de aarde is vol van Zijn glorie (2x)
			"""
			sheet7.time = 59
			sheet7.hasCluster = ikZing
			sheet7.position = 6
			sheet7.deletedAt = Date()
			
			CoreInstrument.predicates.append("resourcePath", notEquals: "LordLoop")
			CoreInstrument.predicates.append("resourcePath", notEquals: "kort")
			let instruments = CoreInstrument.getEntities()
			
			for instrument in instruments {
				instrument.hasCluster = ikZing
			}
		}
		
		CoreCluster.predicates.append("title", equals: "Hij is heer")
		if CoreCluster.getEntities().count == 0 {
			let heIsLord = CoreCluster.createEntity()
			heIsLord.title = "Hij is heer"
			heIsLord.deletedAt = Date()
			heIsLord.isLoop = true
			
			CoreTheme.predicates.append("title", equals: "Songs")
			let songsTheme: VTheme
			if let existingTheme = CoreTheme.getEntities().first {
				songsTheme = existingTheme
			} else {
				let newTheme = CoreTheme.createEntity()
				newTheme.title = "Songs"
				newTheme.deletedAt = Date()
				newTheme.isHidden = true
				songsTheme = newTheme
			}
			
			heIsLord.hasTheme = songsTheme
			
			let lordSheet = CoreSheetTitleContent.createEntity()
			lordSheet.title = "Hij is heer."
			lordSheet.time = Double.greatestFiniteMagnitude
			lordSheet.hasCluster = heIsLord
			lordSheet.position = 0
			lordSheet.lyrics = """
			Want Hij is heer, Hij is heer.
			Hij is opgestaan, want Jezus Hij is heer.
			Elke knie zal zich buigen, elke tong belijden.
			Dat Jezus, Hij is heer.
			"""
			
			CoreInstrument.predicates.append("resourcePath", equals: "LordLoop")
			let lordLoop = CoreInstrument.getEntities().first
			
			CoreInstrument.predicates.append("resourcePath", equals: "LordSong")
			let lordSong = CoreInstrument.getEntities()
			
			lordSong.forEach({ $0.hasCluster = heIsLord })
			
			lordLoop?.hasCluster = heIsLord
			CoreCluster.saveContext()
		}
		
		CoreCluster.predicates.append("title", equals: "Test kort")
		if CoreCluster.getEntities().count == 0 {
			let kort = CoreCluster.createEntity()
			kort.title = "Test kort"
			kort.deletedAt = Date()
			
			CoreTheme.predicates.append("title", equals: "Security")
			let tag = CoreTheme.getEntities().first
			
			kort.hasTag = tag
			
			let sheet1 = CoreSheetTitleContent.createEntity()
			sheet1.title = "Test kort"
			sheet1.lyrics = """
			Test kort
			"""
			sheet1.time = 3
			sheet1.hasCluster = kort
			sheet1.position = 0
			sheet1.deletedAt = Date()
			
			let sheet2 = CoreSheetTitleContent.createEntity()
			sheet2.title = "Test Kort 1"
			sheet2.lyrics = """
			test kort 1
			"""
			sheet2.time = 3
			sheet2.hasCluster = kort
			sheet2.position = 1
			sheet2.deletedAt = Date()
			
			let sheet3 = CoreSheetTitleContent.createEntity()
			sheet3.title = "Test kort 2"
			sheet3.lyrics = """
			Test kort 2
			"""
			sheet3.time = Double.infinity
			sheet3.hasCluster = kort
			sheet3.position = 2
			sheet3.deletedAt = Date()
			
			CoreInstrument.predicates.append("resourcePath", equals: "kort")
			let instruments = CoreInstrument.getEntities()
			
			for instrument in instruments {
				instrument.hasCluster = kort
			}
		}
		
		
		
	}
	
	private func setupAirPlay() {
		
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
		checkForExternalDisplay()

	}
	
	func displayConnected(notification: Notification) {
		checkForExternalDisplay()
	}
	
	func checkForExternalDisplay() {
		if UIScreen.screens.count > 1 {
			guard let screen = UIScreen.screens.last
				else { return }
			print(screen.bounds)
			if externalDisplayWindow == nil {
				externalDisplayWindow = UIWindow(
					frame: screen.bounds
				)
				externalDisplayWindow?.screen = screen
				NotificationCenter.default.post(name: NotificationNames.externalDisplayDidChange, object: nil, userInfo: nil)
				externalDisplayWindow?.isHidden = false
			}
			
		}
	}
	
	func displayDisconnected(notification: Notification) {
		externalDisplayWindow?.isHidden = true
		externalDisplayWindow = nil
		NotificationCenter.default.post(name: NotificationNames.externalDisplayDidChange, object: nil, userInfo: nil)
	}

}

