//
//  EdgeInsetExtension.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/09/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

extension UIEdgeInsets {
    
    init(cgFloat: CGFloat) {
        self.init(top: cgFloat, left: cgFloat, bottom: cgFloat, right: cgFloat)
    }
}
