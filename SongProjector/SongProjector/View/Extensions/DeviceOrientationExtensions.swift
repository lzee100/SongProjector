//
//  DeviceOrientationExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 20/04/2021.
//  Copyright © 2021 iozee. All rights reserved.
//

import UIKit

extension UIDeviceOrientation {
    
    static var isPortrait: Bool {
        let portraitOrientations: [UIDeviceOrientation] = [.landscapeLeft, .landscapeRight]
        return !portraitOrientations.contains(UIDevice.current.orientation)
    }
    
    static var isLandscape: Bool {
        return !isPortrait
    }
    
    var isPortrait: Bool {
        ![.landscapeLeft, .landscapeRight].contains(self)
    }
    
    var isLandscape: Bool {
        [.landscapeLeft, .landscapeRight].contains(self)
    }

}
