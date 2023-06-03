//
//  DeleteFileAtURLUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct DeleteFileAtURLUseCase {
    
    private let fileName: String
    
    init?(fileName: String?) {
        if let fileName {
            self.fileName = fileName
        } else {
            return nil
        }
    }
    
    func delete(location: GetFileURLUseCase.Location = .persitent) throws {
        let url = GetFileURLUseCase(fileName: fileName).getURL(location: location)
        try FileManager.default.removeItem(at: url)
    }
    
}
