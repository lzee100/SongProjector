//
//  CreateChurchBeamDirectoryUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct CreateChurchBeamDirectoryUseCase {
    
    private let location: GetFileURLUseCase.Location
    
    init(location: GetFileURLUseCase.Location) {
        self.location = location
    }
    
    func create() throws {
        let directory = "churchbeam"
        let url: URL
        switch location {
        case .temp: url = URL.churchbeamDirectoryTemp
        case .persitent: url = URL.churchbeamDirectory
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
}
