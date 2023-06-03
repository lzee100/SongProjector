//
//  GetFileURLUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct GetFileURLUseCase {
    
    enum Location {
        case temp
        case persitent
    }
    
    let fileName: String
    private let churchbeamFolder = "churchbeam"
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    init(fileType: FileType) {
        self.fileName = Self.getNameFor(fileType)
    }
    
    func getURL(location: Location) -> URL {
        let url: URL
        switch location {
        case .temp: url = URL.temporaryDirectory
        case .persitent: url = URL.documentsDirectory
        }
        return url.appending(component: churchbeamFolder, directoryHint: .isDirectory).appending(path: fileName, directoryHint: .notDirectory)
    }
    
    private static func getNameFor(_ fileType: FileType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let stringDate = dateFormatter.string(from: Date())
        
        let name = stringDate + UUID().uuidString + ".\(fileType.rawValue)"
        
        return name
    }

}
