
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
//		setupAndCheckDatabase()
		setupAirPlay()
		ChurchBeamConfiguration.environment = .localhost
//		let entities = CoreEntity.getEntities()
//		entities.forEach({ $0.delete(false) })
//		CoreEntity.saveContext(fireNotification: true)
		
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
		GIDSignIn.sharedInstance()?.clientID = "1005753122128-dc0k48rg97hdetif0g3ncaf0dq0ue6mc.apps.googleusercontent.com"
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

	
	
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		// print("application application: \(application.description), openURL: \(url.absoluteURL), sourceApplication: \(sourceApplication)")
		
//		AWSMobileClient.sharedInstance().interceptApplication(
//			application, open: url,
//			sourceApplication: sourceApplication,
//			annotation: annotation)
//
//		AWSSignInManager.sharedInstance().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//		isInitialized = true
		
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		
//		return AWSMobileClient.sharedInstance().interceptApplication(
//			app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation]!)
		
//		return GIDSignIn.sharedInstance().handle(url,
//													sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
//													annotation: options[UIApplicationOpenURLOptionsKey.annotation])
		return true
	}
	
	

//	private func setupAndCheckDatabase() {
//
//		// remove temporary sheets or tags that were created but session got lost (app terminated durring configuration process)
//		CoreEntity.getTemp = true
//		var entities = CoreEntity.getEntities()
//		entities.forEach({ $0.delete(false) })
//		CoreEntity.saveContext(fireNotification: false)
//		CoreEntity.getTemp = false
//
//		let predicate = NSPredicate(format: "title == %@", 0)
//		CoreEntity.predicates.append(and: [predicate])
//		entities = CoreEntity.getEntities()
//		for entity in entities {
//			_ = CoreEntity.delete(entity: entity)
//		}
//
//		entities = CoreTag.getEntities()
//		for entity in entities {
//			_ = CoreEntity.delete(entity: entity)
//		}
//
//		CoreTag.predicates.append("title", equals: "Player")
//		var tags = CoreTag.getEntities()
//		if tags.count == 0 {
//			let tag = CoreTag.createEntity()
//			tag.title = "Player"
//			tag.deleteDate = nil
//			let _ = CoreTag.saveContext()
//		}
//		CoreTag.predicates.append("title", equals: "Songs")
//		tags = CoreTag.getEntities()
//		if tags.count == 0 {
//			let tag = CoreTag.createEntity()
//			tag.title = "Songs"
//			tag.deleteDate = nil
//			let _ = CoreTag.saveContext()
//		}
//		CoreTag.predicates.append("title", equals: "Security")
//		tags = CoreTag.getEntities()
//		if tags.count == 0 {
//			let tag = CoreTag.createEntity()
//			tag.deleteDate = nil
//			tag.title = "Security"
//			let _ = CoreTag.saveContext()
//		}
//
//		CoreInstrument.predicates.append("resourcePath", equals: "kort")
//		let kort = CoreInstrument.getEntities()
//		if kort.count == 0 {
//			let kort = CoreInstrument.createEntity()
//			kort.type = .piano
//			kort.resourcePath = "kort"
//			kort.isLoop = false
//			kort.deleteDate = nil
//			kort.title = "kort"
//		}
//
//
//		CoreInstrument.predicates.append("resourcePath", equals: "LordLoop")
//		let lord = CoreInstrument.getEntities()
//		if lord.count == 0 {
//			let lord = CoreInstrument.createEntity()
//			lord.type = .pianoSolo
//			lord.resourcePath = "LordLoop"
//			lord.isLoop = true
//			lord.deleteDate = nil
//			lord.title = "LordLoop"
//		}
//
//		CoreInstrument.predicates.append("resourcePath", equals: "LordSong")
//		let lordSong = CoreInstrument.getEntities()
//		if lordSong.count == 0 {
//			let lordSong = CoreInstrument.createEntity()
//			lordSong.type = .piano
//			lordSong.resourcePath = "LordSong"
//			lordSong.isLoop = true
//			lordSong.deleteDate = nil
//			lordSong.title = "LordSong"
//		}
//
//		CoreInstrument.predicates.append("typeString", equals: "Keyboard")
//		let pianos = CoreInstrument.getEntities()
//		if pianos.count == 0 {
//			let piano = CoreInstrument.createEntity()
//			piano.type = .piano
//			piano.resourcePath = "Keyboard"
//			piano.title = "piano"
//			piano.deleteDate = nil
//		}
//
//		CoreInstrument.predicates.append("typeString", equals: "Guitar")
//		let guitars = CoreInstrument.getEntities()
//		if guitars.count == 0 {
//			let guitar = CoreInstrument.createEntity()
//			guitar.type = .guitar
//			guitar.resourcePath = "Guitar"
//			guitar.title = "guitar"
//			guitar.deleteDate = nil
//		}
//
//		CoreInstrument.predicates.append("typeString", equals: "Bass")
//		let bassGuitars = CoreInstrument.getEntities()
//		if bassGuitars.count == 0 {
//			let bassGuitar = CoreInstrument.createEntity()
//			bassGuitar.type = .bassGuitar
//			bassGuitar.resourcePath = "Bass"
//			bassGuitar.title = "bassGuitar"
//			bassGuitar.deleteDate = nil
//		}
//
//		CoreInstrument.predicates.append("typeString", equals: "Drums")
//		let drums = CoreInstrument.getEntities()
//		if drums.count == 0 {
//			let drum = CoreInstrument.createEntity()
//			drum.type = .drums
//			drum.resourcePath = "Drums"
//			drum.title = "drums"
//			drum.deleteDate = nil
//		}
//
//		let _ = CoreInstrument.saveContext()
//
//		CoreCluster.predicates.append("title", equals: "Ik zing vol blijdschap en lach")
//		if CoreCluster.getEntities().count == 0 {
//			let ikZing = CoreCluster.createEntity()
//			ikZing.title = "Ik zing vol blijdschap en lach"
//			ikZing.deleteDate = nil
//
//			CoreTag.predicates.append("title", equals: "Security")
//			let tag = CoreTag.getEntities().first
//
//			ikZing.hasTag = tag
//
//			let sheet1 = CoreSheetTitleContent.createEntity()
//			sheet1.title = "Ik zing vol blijdschap en lach"
//			sheet1.content = """
//			Ik zing vol blijdschap en lach
//			Want de vreugde van God is mijn kracht
//			Wij buigen neer aanbidden Hem nu,
//			hoe groot en machtig is Hij
//			Iedereen zingt, iedereen zingt
//			"""
//			sheet1.time = 36
//			sheet1.hasCluster = ikZing
//			sheet1.position = 0
//			sheet1.deleteDate = nil
//
//			let sheet2 = CoreSheetTitleContent.createEntity()
//			sheet2.title = "Heilig is de heer"
//			sheet2.content = """
//			Heilig is de Heer, God almachtig
//			de aarde is vol van Zijn glorie (2x)
//			"""
//			sheet2.time = 26.80
//			sheet2.hasCluster = ikZing
//			sheet2.position = 1
//			sheet2.deleteDate = nil
//
//			let sheet3 = CoreSheetTitleContent.createEntity()
//			sheet3.title = "Ik zing vol blijdschap en lach"
//			sheet3.content = """
//			Ik zing vol blijdschap en lach
//			Want de vreugde van God is mijn kracht
//			Wij buigen neer aanbidden Hem nu,
//			hoe groot en machtig is Hij
//			Iedereen zingt, iedereen zingt
//			"""
//			sheet3.time = 29.70
//			sheet3.hasCluster = ikZing
//			sheet3.position = 2
//			sheet3.deleteDate = nil
//
//
//			let sheet4 = CoreSheetTitleContent.createEntity()
//			sheet4.title = "Heilig is de heer"
//			sheet4.content = """
//			Heilig is de Heer, God almachtig
//			de aarde is vol van Zijn glorie (2x)
//			"""
//			sheet4.time = 27
//			sheet4.hasCluster = ikZing
//			sheet4.position = 3
//			sheet4.deleteDate = nil
//
//			let sheet5 = CoreSheetTitleContent.createEntity()
//			sheet5.title = "Hij komt terug"
//			sheet5.content = """
//			Hij komt terug, Hij heeft het beloofd
//			voor iedereen die in Hem geloofd (2X)
//			"""
//			sheet5.time = 24.10
//			sheet5.hasCluster = ikZing
//			sheet5.position = 4
//			sheet5.deleteDate = nil
//
//
//			let sheet6 = CoreSheetTitleContent.createEntity()
//			sheet6.title = "Iedereen zingt"
//			sheet6.content = """
//			Iedereen zingt, iedereen zingt
//			"""
//			sheet6.time = 10
//			sheet6.hasCluster = ikZing
//			sheet6.position = 5
//			sheet6.deleteDate = nil
//
//			let sheet7 = CoreSheetTitleContent.createEntity()
//			sheet7.title = "Heilig is de heer"
//			sheet7.content = """
//			Heilig is de Heer, God almachtig
//			de aarde is vol van Zijn glorie (2x)
//			"""
//			sheet7.time = 59
//			sheet7.hasCluster = ikZing
//			sheet7.position = 6
//			sheet7.deleteDate = nil
//
//			CoreInstrument.predicates.append("resourcePath", notEquals: "LordLoop")
//			CoreInstrument.predicates.append("resourcePath", notEquals: "kort")
//			let instruments = CoreInstrument.getEntities()
//
//			for instrument in instruments {
//				instrument.hasCluster = ikZing
//			}
//		}
//
//		CoreCluster.predicates.append("title", equals: "Hij is heer")
//		if CoreCluster.getEntities().count == 0 {
//			let heIsLord = CoreCluster.createEntity()
//			heIsLord.title = "Hij is heer"
//			heIsLord.deleteDate = nil
//			heIsLord.isLoop = true
//
//			CoreTag.predicates.append("title", equals: "Songs")
//			let songsTag: Tag
//			if let existingTag = CoreTag.getEntities().first {
//				songsTag = existingTag
//			} else {
//				let newTag = CoreTag.createEntity()
//				newTag.title = "Songs"
//				newTag.deleteDate = nil
//				newTag.isHidden = true
//				songsTag = newTag
//			}
//
//			heIsLord.hasTag = songsTag
//
//			let lordSheet = CoreSheetTitleContent.createEntity()
//			lordSheet.title = "Hij is heer."
//			lordSheet.time = Double.greatestFiniteMagnitude
//			lordSheet.hasCluster = heIsLord
//			lordSheet.position = 0
//			lordSheet.content = """
//			Want Hij is heer, Hij is heer.
//			Hij is opgestaan, want Jezus Hij is heer.
//			Elke knie zal zich buigen, elke tong belijden.
//			Dat Jezus, Hij is heer.
//			"""
//
//			CoreInstrument.predicates.append("resourcePath", equals: "LordLoop")
//			let lordLoop = CoreInstrument.getEntities().first
//
//			CoreInstrument.predicates.append("resourcePath", equals: "LordSong")
//			let lordSong = CoreInstrument.getEntities()
//
//			lordSong.forEach({ $0.hasCluster = heIsLord })
//
//			lordLoop?.hasCluster = heIsLord
//			CoreCluster.saveContext()
//		}
//
//		CoreCluster.predicates.append("title", equals: "Test kort")
//		if CoreCluster.getEntities().count == 0 {
//			let kort = CoreCluster.createEntity()
//			kort.title = "Test kort"
//			kort.deleteDate = nil
//
//			CoreTag.predicates.append("title", equals: "Security")
//			let tag = CoreTag.getEntities().first
//
//			kort.hasTag = tag
//
//			let sheet1 = CoreSheetTitleContent.createEntity()
//			sheet1.title = "Test kort"
//			sheet1.content = """
//			Test kort
//			"""
//			sheet1.time = 3
//			sheet1.hasCluster = kort
//			sheet1.position = 0
//			sheet1.deleteDate = nil
//
//			let sheet2 = CoreSheetTitleContent.createEntity()
//			sheet2.title = "Test Kort 1"
//			sheet2.content = """
//			test kort 1
//			"""
//			sheet2.time = 3
//			sheet2.hasCluster = kort
//			sheet2.position = 1
//			sheet2.deleteDate = nil
//
//			let sheet3 = CoreSheetTitleContent.createEntity()
//			sheet3.title = "Test kort 2"
//			sheet3.content = """
//			Test kort 2
//			"""
//			sheet3.time = Double.infinity
//			sheet3.hasCluster = kort
//			sheet3.position = 2
//			sheet3.deleteDate = nil
//
//			CoreInstrument.predicates.append("resourcePath", equals: "kort")
//			let instruments = CoreInstrument.getEntities()
//
//			for instrument in instruments {
//				instrument.hasCluster = kort
//			}
//		}
//
//
//
//	}
	
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

