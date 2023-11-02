//
//  SceneDelegate.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    @StateObject var subscriptionsStore = SubscriptionsStore()
    var fetchSubscriptionsTask: Task<(), Never>?

    func scene(_ scene: UIScene,
       willConnectTo session: UISceneSession,
       options connectionOptions: UIScene.ConnectionOptions) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
          let scene = scene as? UIWindowScene else {
          return
        }
        
        if session.role == UISceneSession.Role.windowExternalDisplayNonInteractive {
            let window = UIWindow(windowScene: scene)
            
            let content = ExternalDisplayView(externalDisplayConnector: appDelegate.store)
            content.edgesIgnoringSafeArea(.all)
            window.rootViewController = UIHostingController(rootView: content)
            window.isHidden = false
            externalDisplayWindow = window
        } else {
            window = UIWindow(windowScene: scene)
            let content = ChurchBeamApp(store: appDelegate.store, subscriptionsStore: subscriptionsStore)
            window?.rootViewController = UIHostingController(rootView: content)
            window?.makeKeyAndVisible()
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        fetchSubscriptionsTask = Task {
            await subscriptionsStore.fetchActiveTransactions()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        fetchSubscriptionsTask?.cancel()
    }

}
