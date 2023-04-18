//
//  GrayButtonConfiguration.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct GrayButtonConfigurationStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.xNormal)
            .foregroundColor(configuration.isPressed ? .white : .black.opacity(0.8))
            .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            .background(
                Capsule().fill(configuration.isPressed ? Color(uiColor: themeHighlighted) : .gray.opacity(0.2))
            )
            .cornerRadius(10)
    }
    
}
