//
//  LoadImageUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit

struct LoadImageUseCase {
    
    private let name: String
    
    init?(name: String?) {
        if let name {
            self.name = name
        } else {
            return nil
        }
    }
    
    func loadImage() throws -> UIImage? {
        let getURLUseCase = GetFileURLUseCase(fileName: name)
        let url = getURLUseCase.getURL(location: .persitent)
        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }
}
