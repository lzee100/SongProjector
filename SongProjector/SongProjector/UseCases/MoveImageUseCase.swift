//
//  MoveImageUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct MoveImageUseCase {
        
    @discardableResult
    func moveImageFromTempToNewPersistantDirectory(_ fileName: String) throws -> String {
        let tempURL = GetFileURLUseCase(fileName: fileName).getURL(location: .temp)
        let destinationURL = GetFileURLUseCase(fileName: fileName).getURL(location: .persitent)
        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
        return fileName
    }
    
}
