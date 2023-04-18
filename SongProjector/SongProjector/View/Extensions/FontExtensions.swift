//
//  FontExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

extension Font {
    
    // MARK: - Types
    
    enum Fonts: String {
        case heavy = "HelveticaNeue-CondensedBlack"
        case bold = "Avenir-Heavy"
        case normal = "Avenir"
        case light = "GillSans-Light"
    }
    
    enum Size: CGFloat {
        case xxxLarge = 35.0
        case xxLarge = 30.0
        case xLarge = 25.0
        case large = 20.0
        case xxNormal = 18
        case xNormal = 16.0
        case normal = 14.0
        case small = 12.0
        
        var textStyle: TextStyle {
            switch self {
            case .xxxLarge:
                return .largeTitle
            case .xxLarge, .xLarge:
                return .title
            case .large:
                return .title2
            case .xxNormal:
                return .title
            case .xNormal, .normal:
                return .body
            case .small:
                return .caption
            }
        }
    }
    
    
    
    // MARK: - Properties
    
    var fontSizeText:CGFloat { return 14.0 }
    var fontSizeTextSmall:CGFloat { return 12.0 }
    
    
    var fontSizeIntroHeader:CGFloat { return 35.0 }
    var fontSizeIntroFooter:CGFloat { return 20.0 }
    
    static let introHeader = fontWith(name: .bold, size: .xxLarge)
    static let introFooter = fontWith(name: .light, size: .xLarge)
    
    static let xxxLarge = fontWith(name: .normal, size: .xxxLarge)
    static let xxxLargeBold = fontWith(name: .bold, size: .xxxLarge)
    static let xxxLargeLight = fontWith(name: .light, size: .xxxLarge)

    static let xLarge = fontWith(name: .normal, size: .xLarge)
    static let xLargeBold = fontWith(name: .bold, size: .xLarge)
    static let xLargeLight = fontWith(name: .light, size: .xLarge)
    
    static let large = fontWith(name: .normal, size: .large)
    static let largeBold = fontWith(name: .bold, size: .large)
    static let largeLight = fontWith(name: .light, size: .large)
    
    static let xxNormal = fontWith(name: .normal, size: .xxNormal)
    static let xxNormalBold = fontWith(name: .bold, size: .xxNormal)
    static let xxNormalLight = fontWith(name: .light, size: .xxNormal)
    
    static let xNormal = fontWith(name: .normal, size: .xNormal)
    static let xNormalBold = fontWith(name: .bold, size: .xNormal)
    static let xNormalLight = fontWith(name: .light, size: .xNormal)
    
    static let normal = fontWith(name: .normal, size: .normal)
    static let normalBold = fontWith(name: .bold, size: .normal)
    static let normalLight = fontWith(name: .light, size: .normal)
    
    static let small = fontWith(name: .normal, size: .small)
    static let smallBold = fontWith(name: .bold, size: .small)
    static let smallLight = fontWith(name: .light, size: .small)
    
    
    
    // MARK: - Functions
    
    static func fontWith(name: Fonts = .normal, size: Size = .normal) -> Font {
        Font.custom(name.rawValue, size: size.rawValue, relativeTo: size.textStyle)
    }
    
    
}
