//
//  FrameSizeAndRatioModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct FrameSizeAndRatioModifier: ViewModifier {
    
    let displaySize: CGSize
    private var width: CGFloat {
//        if displaySize.width > displaySize.height {
//            return getSizeWith(height: displaySize.height).width
//        } else {
//            return getSizeWith(width: displaySize.width).width
//        }
        return 0
    }
        
    func body(content: Content) -> some View {
        content
            .aspectRatio(externalDisplayWindowRatio, contentMode: .fit)
    }
    
}

extension View {
    
    func styleFrameAndRatio(for displaySize: CGSize) -> some View {
        self.modifier(FrameSizeAndRatioModifier(displaySize: displaySize))
    }
}

