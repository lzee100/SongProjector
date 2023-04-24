//
//  SheetBackgroundColorAndOpacityModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


struct SheetBackgroundColorAndOpacityModifier: ViewModifier {
    
    private let sheetTheme: ThemeCodable?
    private var backgroundColor: Color? {
        sheetTheme?.sheetBackgroundColor?.color
    }
    private var backgroundOpacity: Double {
        let transparancy = sheetTheme?.backgroundTransparancyNumber
        return transparancy ?? 0.0
    }

    init(sheetTheme: ThemeCodable?) {
        self.sheetTheme = sheetTheme
    }
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor ?? .white)
            .opacity(backgroundOpacity)
    }
    
}
