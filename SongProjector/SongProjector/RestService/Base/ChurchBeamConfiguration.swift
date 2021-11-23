//
//  ChurchBeamConfiguration.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn
import FirebaseAuth

let ChurchBeamConfiguration = Config()

class Config: NSObject {
	
	
	fileprivate struct Keys {
		
		static let Environment = "config.environment"
		static let BundleVersion = "CFBundleShortVersionString"
		static let BuildTargetType = "BuildTargetType"
		static let AppStoreIdentifier = "AppStoreIdentifier"
		static let RESTServiceVersion = "RESTServiceVersion"
		static let BundleName = "CFBundleName"
	}
	
	lazy var appVersion: String = {
		let versionString = Bundle.main.infoDictionary?[Keys.BundleVersion] as? String
		if let versionString = versionString {
			return versionString
		}
		return "Onbekend"
	}()
	
	lazy var bundleName: String = {
		if let bundleName = Bundle.main.infoDictionary?[Keys.BundleName] as? String {
			return bundleName
		}
		return "Unknown"
	}()
	
	lazy var appStoreId: NSNumber? = {
		
		if let appStoreId = Bundle.main.infoDictionary?[Keys.AppStoreIdentifier] as? NSNumber {
			return appStoreId
		}
		return nil
	}()
	
	lazy var appStoreURL: URL? = {
		
		if let appStoreId = self.appStoreId {
			
			let iTunesString = "https://itunes.apple.com/app/id\(appStoreId.stringValue)"
			return URL(string: iTunesString)
		}
		return nil
	}()
	
	var environment: Environment {
		get {
			let int = UserDefaults.standard.integer(forKey: Keys.Environment)
			if int != 0 {
				if let env = Environment(rawValue: int) {
					return env
				}
			}
            return Environment.production
		}
		set {
			if environment != newValue {
				UserDefaults.standard.set(newValue.rawValue, forKey: Keys.Environment)
				NotificationCenter.default.post(name: .environmentChanged, object: nil)
			}
		}
	}
	
	lazy var applicationDocumentsDirectory: URL = {
		
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count - 1]
	}()
		
}

enum Environment: Int {
	
	static let allValues = [dev, production]
	
	case dev = 1
	case production = 2
	
	var name: String {
		switch self {
		case .dev:
			return AppText.environments.development
		case .production:
			return AppText.environments.production
		}
	}
    
    var next: Environment {
        return self == .dev ? .production : .dev
    }
}

extension Environment {
    
    func loadGoogleFile() {
        switch self {
        case .production:
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
            guard let fileopts = FirebaseOptions(contentsOfFile: filePath!) else {
                assert(false, "Couldn't load config file")
                return
            }
//            FirebaseApp.configure(options: fileopts)
            FirebaseApp.configure()
        case .dev:
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-Test", ofType: "plist")
            guard let fileopts = FirebaseOptions(contentsOfFile: filePath!) else {
                assert(false, "Couldn't load config file")
                return
            }
            FirebaseApp.configure(options: fileopts)
        }
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = UIApplication.shared.delegate as? GIDSignInDelegate
    }
}
