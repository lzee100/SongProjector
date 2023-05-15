//
//  testUIApp.swift
//  testUI
//
//  Created by Leo van der Zee on 11/05/2023.
//

import SwiftUI
import UserNotifications
import CoreData
import Photos
import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import Network

@main
struct ChurchBeamApp: App {
    
    private let soundPlayer = SoundPlayer2()
    
    init() {
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
    }
    
    var body: some Scene {
        WindowGroup {
            TabViewUI()
                .environmentObject(soundPlayer)
        }
    }
}
