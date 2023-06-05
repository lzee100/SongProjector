//
//  SheetViewModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetRatioAndShadowModifier: ViewModifier {
    
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
}

extension View {
    
    func applySheetRatioAndShadow() -> some View {
        self.modifier(SheetRatioAndShadowModifier())
    }
}


