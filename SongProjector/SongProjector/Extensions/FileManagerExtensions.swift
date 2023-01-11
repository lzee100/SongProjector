//
//  FileManagerExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

enum FileManagerError: Error {
    case noFileName
    case cannotCreateTempDir
}

extension FileManager {
	
	/// existing path will be used to remove previous item at path
	static func set(data: Data, existingPath: String? = nil, fileType: String) throws -> String {
		if let path = existingPath {
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let url = documentsDirectory.appendingPathComponent(path)
			try FileManager.default.removeItem(at: url)
		}
		
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

		try createDirectory()

		let newDataPath = UUID().uuidString + ".\(fileType)"
		
		let filename = documentsDirectory.appendingPathComponent(newDataPath)
		
		try? data.write(to: filename)
		
		return newDataPath
	}
	
	static func getDataFrom(existingPath: String, fileType: String) -> Data? {
		
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let dataPath = documentsDirectory
			.appendingPathComponent("churchbeam")
			.appendingPathComponent(existingPath)
		
		
		if FileManager.default.fileExists(atPath: dataPath.absoluteString) {
			return FileManager.default.contents(atPath: dataPath.absoluteString)
		} else {
			return nil
		}
	}
	
	static func appFullPathTemp(existingPath: String?) -> String? {
		guard let existingPath = existingPath else { return nil }
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		return documentsDirectory
			.appendingPathComponent(existingPath).absoluteString
	}
	
	static func appFullPath(existingPath: String?) -> String? {
		guard let existingPath = existingPath else { return nil }
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		return documentsDirectory
		.appendingPathComponent("churchbeam")
			.appendingPathComponent(existingPath).absoluteString
	}
	
	static func getUrlFor(fileName: String?) throws -> URL? {
        try createDirectory()
		guard let fileName = fileName else { return nil }
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		return documentsDirectory
		.appendingPathComponent("churchbeam")
			.appendingPathComponent(fileName, isDirectory: false)
	}
    

    static func getNewTempUrlFor(fileName: String?) throws -> URL {
        try createTempDirectory()
        guard let fileName = fileName else {
            throw FileManagerError.noFileName
        }
        let tempDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName, isDirectory: false)
        do {
            try FileManager.default.removeItem(at: tempDirURL)
        } catch {}
        try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        return tempDirURL
    }
    
    static func getTempURLFor(name: String) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(name, isDirectory: false)
    }
	
	static func createDirectory() throws {
		let documentsDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
		let dataPath = documentsDirectory.appendingPathComponent("churchbeam")
		switch dataPath?.filestatus {
		case .notExisting:
			if let url = URL.createFolder(folderName: "churchbeam") {
				print(url)
			} else {
				print("")
			}
		default: return
		}
	}
    
    static func createTempDirectory() throws {
        let dataPath = FileManager.default.temporaryDirectory.appendingPathComponent("churchbeam")
        switch dataPath.filestatus {
        case .notExisting:
            if let url = URL.createFolder(folderName: "churchbeam") {
                print(url)
            } else {
                print("")
            }
        default: return
        }
    }
	
	static func getNameFor(fileType: FileType) throws -> String {
        try createDirectory()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMddHHmmssss"
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

		let stringDate = dateFormatter.string(from: Date())
		
        let newDataPath = stringDate + UUID().uuidString + ".\(fileType.rawValue)"
		
		return newDataPath
	}
    
    static func getNameForTemp(fileType: FileType) throws -> String {
        try createTempDirectory()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let stringDate = dateFormatter.string(from: Date())
        
        let newDataPath = stringDate + UUID().uuidString + ".\(fileType.rawValue)"
        
        return newDataPath
    }

    
    static func getURLfor(name: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("churchbeam").appendingPathComponent(name, isDirectory: false)
    }
    
    static func fileExists(path: String) -> Bool {
        var isDir : ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory:&isDir)
    }
    
    static func deleteFile(name: String) throws {
        let path = getURLfor(name: name)
        if fileExists(path: path.absoluteString) {
            try FileManager.default.removeItem(at: path)
        }
    }


}

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}
