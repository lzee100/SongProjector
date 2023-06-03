//
//  DeleteAllFilesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct DeleteAllFilesUseCase {
    
    private let churchbeamDirectory = "churchbeam"
    
    func delete() throws {
        try FileManager.default.removeItem(at: URL.churchbeamDirectory)
        try FileManager.default.removeItem(at: URL.churchbeamDirectoryTemp)
    }
}
