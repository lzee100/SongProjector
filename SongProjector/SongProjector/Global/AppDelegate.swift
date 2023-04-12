
//
//  AppDelegate.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import Photos
import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import Network

let ApplicationIdentifier = "ApplicationIdentifier"
var hasInternet = true

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

func getScaleFactor(width: CGFloat) -> CGFloat {
    return width / 250
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    //Used for checking whether Push Notification is enabled in Amazon Pinpoint
    static let remoteNotificationKey = "RemoteNotification"
    var isInitialized: Bool = false
    private var isRegistered: Bool {
        let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
        return user != nil
    }
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance(whenContainedInInstancesOf: [UISplitViewController.self]).tintColor = themeHighlighted
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: ApplicationIdentifier) == nil {
            let UUID = NSUUID().uuidString
            userDefaults.set(UUID, forKey: ApplicationIdentifier)
        }
        let intvalue = Date().intValue
        if UserDefaults.standard.integer(forKey: "config.environment") != 0 {
            ChurchBeamConfiguration.environment.loadGoogleFile()
        } else {
            switch AppConfiguration.mode {
            case .TestFlight, .AppStore:
                ChurchBeamConfiguration.environment = .production
            case .Debug:
                ChurchBeamConfiguration.environment = .dev
            }
            ChurchBeamConfiguration.environment.loadGoogleFile()
        }
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        setupAirPlay()

        UNUserNotificationCenter.current().delegate = self
        
        NotificationCenter.default.addObserver(forName: .checkAuthentication, object: nil, queue: .main) { (_) in
            self.checkAuthentication()
        }
        if SystemInfo.sharedInstance.isDebugMode() == .debug {
            PopUpTimeManager.resetAll()
        }
        
//        let manager = IAPManager(delegate: nil, sharedSecret: "0269d507736f44638d69284ad77f2ba7")
//        manager.refreshSubscriptionsStatus()
//        fixLastShowAt()
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            self?.checkAuthentication()
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        monitor.cancel()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                Task {
                    let hasI = await CheckInternet.checkInternet()
                    hasInternet = hasI
                }
            } else {
                hasInternet = false
            }
            
        }
        monitor.start(queue: queue)

        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        return false
    }
    
    private func setupAirPlay() {
        
        NotificationCenter.default.addObserver(
            forName: UIScreen.didConnectNotification,
            object: nil,
            queue: nil,
            using: displayConnected)
        
        NotificationCenter.default.addObserver(
            forName: UIScreen.didDisconnectNotification,
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
            if externalDisplayWindow == nil {
                externalDisplayWindow = UIWindow(
                    frame: screen.bounds
                )
                externalDisplayWindow?.screen = screen
                NotificationCenter.default.post(name: .externalDisplayDidChange, object: nil, userInfo: nil)
                externalDisplayWindow?.isHidden = false
            }
            
        }
    }
    
    func displayDisconnected(notification: Notification) {
        externalDisplayWindow?.isHidden = true
        externalDisplayWindow = nil
        NotificationCenter.default.post(name: .externalDisplayDidChange, object: nil, userInfo: nil)
    }
    
    fileprivate func checkAuthentication() {
        let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
        let userId = user?.userUID
        let authId = Auth.auth().currentUser?.uid
        if userId != nil, authId != nil, userId == authId {
            NotificationCenter.default.post(name: .authenticated, object: nil)
        } else {
            UserDefaults.standard.removeObject(forKey: secretKey)
            UserDefaults.standard.removeObject(forKey: UniversalClusterOperationsPerformed)
            let entities: [Entity] = DataFetcher().getEntities(moc: moc)
            entities.forEach({ moc.delete($0) })
            do {
                try moc.save()
            } catch {
                print(error)
            }
            NotificationCenter.default.post(name: .signedOut, object: nil)
        }
    }
    
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        return completionHandler(UNNotificationPresentationOptions.banner)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    
}


extension AppDelegate {
    
    func fixLastShowAt() {
        let mocBackground = newMOCBackground
        var clusters: [Cluster] = DataFetcher().getEntities(moc: mocBackground)
        guard clusters.contains(where: { $0.lastShownAt?.date.isAfter(Date()) ?? false }) else { return }

        func update(cluster: Cluster) {
            print("started")
            cluster.updateLastShownAt(moc: mocBackground) {
                print("finished")
                clusters.removeFirst()
                checkCluster()
            }
        }

        func checkCluster() {
            if let cluster = clusters.first {
                update(cluster: cluster)
            } else {
                let clusters: [Cluster] = DataFetcher().getEntities(moc: mocBackground)
                let future = clusters.filter({ $0.lastShownAt?.date.isAfter(Date()) ?? false })
                future.forEach({ $0.lastShownAt = nil })
                do {
                    try moc.save()
                } catch {
                }
                
            }
        }
        
        checkCluster()
        
        
    }
    
}

extension Cluster {
    
    func updateLastShownAt(moc: NSManagedObjectContext, completion: @escaping (() -> Void)) {
        Firestore.firestore().collection("clusters").document(self.id).getDocument { [weak self] snapshot, error in
            let cluster: VCluster? = try? snapshot?.decoded()
            self?.lastShownAt = cluster?.lastShownAt as NSDate?
            do {
                try moc.save()
                completion()
            } catch {
                completion()
            }
        }
    }

}
