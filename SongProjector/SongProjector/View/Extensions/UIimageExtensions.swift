//
//  UIimageExtensions.swift
//  
//
//  Created by Leo van der Zee on 13/04/2023.
//

import Foundation
import SwiftUI

extension UIImage {
    var data: Data? {
        self.jpegData(compressionQuality: 1)
    }
    var image: Image? {
        Image(uiImage: self)
    }
}
