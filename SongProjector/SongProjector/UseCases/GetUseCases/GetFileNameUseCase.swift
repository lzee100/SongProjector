//
//  GetFileNameUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct GetFileNameUseCase {
    
    private let pathExtension: String
    
    init(pathExtension: String) {
        self.pathExtension = pathExtension
    }
    
    func getFileName() -> String {
        return UUID().uuidString + dateString + ".\(pathExtension)"
    }
    
    private var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dmyyyyHHmmsss"
        return dateFormatter.string(from: Date())
    }
}
