//
//  CreateChurchBeamDirectoryUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct CreateChurchBeamDirectoryUseCase {
    
    private let churchbeamFolder = "churchbeam"
    
    func setup() {
        do {
            let tempFolderURL = URL.temporaryDirectory.appending(component: churchbeamFolder, directoryHint: .isDirectory)
            let persistentFolderURL = URL.documentsDirectory.appending(component: churchbeamFolder, directoryHint: .isDirectory)
            
            try FileManager.default.createDirectory(at: tempFolderURL, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: persistentFolderURL, withIntermediateDirectories: true)
        } catch {
            print("error CreateChurchBeamDirectoryUseCase: \(error)")
        }
    }
    
}
