//
//  SectionTitleModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SectionTitleModifier: ViewModifier {
        
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            .font(.title3)
            .foregroundColor(.black.opacity(0.8))
    }
}

extension View {
    
    var styleAsSection: some View {
        self.modifier(SectionTitleModifier())
    }
}

