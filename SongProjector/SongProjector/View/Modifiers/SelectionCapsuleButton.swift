//
//  SelectionCapsuleButton.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SelectionCapsuleButton: ViewModifier {
    
    let isSelected: Bool
    
    init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func body(content: Content) -> some View {
        content
            .font(.xNormal)
            .foregroundColor(isSelected ? Color(uiColor: .whiteColor) : Color(uiColor: .blackColor).opacity(0.8))
            .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            .background(
                Capsule().fill(isSelected ? Color(uiColor: themeHighlighted) : .gray.opacity(0.2))
            )
            .cornerRadius(10)
    }
}

extension View {
    func styleAsSelectionCapsuleButton(isSelected: Bool) -> some View {
        self.modifier(SelectionCapsuleButton(isSelected: isSelected))
    }
}
