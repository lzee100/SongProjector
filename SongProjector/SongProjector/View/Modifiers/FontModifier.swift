//
//  FontModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct FontModifier: ViewModifier {
    
    var font: Font = .normal
    var color: Color = Color(uiColor: .blackColor)
    let opacity: CGFloat = 0.8
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color.opacity(0.8))
    }
}

extension View {
    
    func styleAs(font: Font, color: Color = Color(uiColor: .blackColor)) -> some View {
        self.modifier(FontModifier(font: font, color: color))
    }
}
