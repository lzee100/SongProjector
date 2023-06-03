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
    
    func scene(_ scene: UIScene,
       willConnectTo session: UISceneSession,
       options connectionOptions: UIScene.ConnectionOptions) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
          let scene = scene as? UIWindowScene else {
          return
        }
        
        window = UIWindow(windowScene: scene)
        if session.role == UISceneSession.Role.windowExternalDisplayNonInteractive {
            let content = ExternalDisplayView(externalDisplayConnector: appDelegate.store)
            window?.rootViewController = UIHostingController(rootView: content)
            window?.isHidden = false
        } else {
            let content = ChurchBeamApp(store: appDelegate.store)
            window?.rootViewController = UIHostingController(rootView: content)
            window?.makeKeyAndVisible()
        }
    }
    
    

}
