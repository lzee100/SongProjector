//
//  SheetPastorsEntityExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension SheetPastorsEntity {
    func set(image: UIImage?, imageName: String?) throws {
        let savedImage = try UIImage.set(image: image, imageName: imageName ?? imagePath, thumbNailName: thumbnailPath)
        self.imagePath = savedImage.imagePath
        self.thumbnailPath = savedImage.thumbPath
    }
}
