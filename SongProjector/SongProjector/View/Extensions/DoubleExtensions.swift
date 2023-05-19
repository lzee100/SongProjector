//
//  DoubleExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/10/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

extension Double {
    
    var stringValue: String {
        return "\(self)"
    }
    
    var intValue: Int {
        return Int(self)
    }
    
    var oneDecimal: Double {
        return NSString(format: "%.1f", self).doubleValue
    }
    var twoDecimals: Double {
        return NSString(format: "%.2f", self).doubleValue
    }

    var cgFloat: CGFloat {
        return CGFloat(self)
    }

}
