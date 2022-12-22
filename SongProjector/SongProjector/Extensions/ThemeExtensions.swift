//
//  ThemeExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

extension Theme {
    func setDownloadValues(_ downloadObjects: [DownloadObject]) {
        for download in downloadObjects.compactMap({ $0 as DownloadObject }) {
            if imagePathAWS == download.remoteURL.absoluteString {
                do {
                    try setBackgroundImage(image: download.image, imageName: download.filename)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func setBackgroundImage(image: UIImage?, imageName: String?) throws {
        let savedImage = try UIImage.set(image: image, imageName: imageName ?? self.imagePath, thumbNailName: self.imagePathThumbnail)
        self.imagePath = savedImage.imagePath
        self.imagePathThumbnail = savedImage.thumbPath
    }
}
