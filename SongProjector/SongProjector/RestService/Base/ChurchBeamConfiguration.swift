//
//  ChurchBeamConfiguration.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let ChurchBeamConfiguration = Config()

class Config: NSObject {
	
	//Hier aanpassen voor release
	//    static let RestServiceVersion: String = "31"
	let RestServiceVersion: String = "latest"
	
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
			UserDefaults.standard.synchronize()
			let int = UserDefaults.standard.integer(forKey: Keys.Environment)
			if int != 0 {
				if let env = Environment(rawValue: int) {
					return env
				}
			}
			return Environment.localhost
		}
		set {
			if environment != newValue {
				UserDefaults.standard.set(newValue.rawValue, forKey: Keys.Environment)
				UserDefaults.standard.synchronize()
				NotificationCenter.default.post(name: NotificationNames.environmentChanged, object: nil)
			}
		}
	}
	
	lazy var applicationDocumentsDirectory: URL = {
		
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count - 1]
	}()
	
	let supportMailAdress = "churchbeamsupport@gmail.com"
	let endpointChooserUsername = "geon!"
	
}

enum Environment: Int {
	
	static let allValues = [localhost, dev, production]
	
	case localhost = 1
	case dev = 2
	case production = 10
	
	var name: String {
		switch self {
		case .localhost:
			return Text.environments.localHost
		case .dev:
			return Text.environments.development
		case .production:
			return Text.environments.production
		}
	}
	
	var endpoint: String {
		switch self {
		case .localhost:
			return "http://127.0.0.1:3000/"
		case .dev:
			return "https://rest-ontwikkel.parro.com/rest/v1/"
		case .production:
			return "https://rest.parro.com/rest/v1/"
		}
	}
}

