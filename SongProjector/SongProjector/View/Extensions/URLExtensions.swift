//
//  URLExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


extension URL {
    
    static let churchbeamDirectory = URL.documentsDirectory.appending(component: "churchbeam", directoryHint: .isDirectory)
    static let churchbeamDirectoryTemp = URL.temporaryDirectory.appending(component: "churchbeam", directoryHint: .isDirectory)
	
	static func fromString(_ url: String, parameters: [String: Any]?) -> URL? {
		
		if var components = URLComponents(string: url) {
			
			var queryItems: [URLQueryItem] = []
			for (key, value) in parameters ?? [:] {
				if let value = value as? String {
					queryItems.append(URLQueryItem(name: key, value: value))
					
				} else if let value = value as? NSNumber {
					queryItems.append(URLQueryItem(name: key, value: String(format: "%lld", value.int64Value)))
					
				} else if let value = value as? [String] {
					for val in value {
						queryItems.append(URLQueryItem(name: key, value: val))
					}
				} else if let value = value as? [NSNumber] {
					for val in value {
						queryItems.append(URLQueryItem(name: key, value: val.stringValue))
					}
				}
			}
			if queryItems.count > 0 {
				components.queryItems = queryItems
			}
			return components.url
		}
		return nil
	}
	
	public init?(string: String?) {
		
		if let string = string, let url = URL(string: string) {
			self = url
		} else {
			return nil
		}
		
	}
	
	public mutating func append(_ queryItem: URLQueryItem) {
		
		append([queryItem])
		
	}
	
	public mutating func append(_ queryItems: [URLQueryItem]) {
		
		if
			!queryItems.isEmpty,
			var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
			
			var items = components.queryItems ?? []
			items.append(contentsOf: queryItems)
			components.queryItems = items
			
			if let url = components.url {
				self = url
			}
			
		}
		
	}
	
	var filestatus: Filestatus {
		get {
			let filestatus: Filestatus
			var isDir: ObjCBool = false
			if FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir) {
				if isDir.boolValue {
					filestatus = .isDir
				} else {
					filestatus = .isFile
				}
			}
			else {
				filestatus = .notExisting
			}
			return filestatus
		}
	}
}
enum Filestatus {
	case isFile
	case isDir
	case notExisting
}

