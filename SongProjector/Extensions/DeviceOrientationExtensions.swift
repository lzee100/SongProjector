//
//  DeviceOrientationExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 20/04/2021.
//  Copyright © 2021 iozee. All rights reserved.
//

import UIKit

extension UIDeviceOrientation {
    
    var isPortrait: Bool {
        let portraitOrientations: [UIDeviceOrientation] = [.faceDown, .faceDown, .portrait, .portraitUpsideDown]
        return portraitOrientations.contains(UIDevice.current.orientation)
    }
    
    var isLandscape: Bool {
        return !isPortrait
    }
}
