//
//  SheetBackgroundColorAndOpacityModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI


struct SheetBackgroundColorAndOpacityModifier: ViewModifier {
    
    var displayModel: SheetDisplayViewModel?
    @ObservedObject private var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    init(displayModel: SheetDisplayViewModel? = nil, editViewModel: WrappedStruct<EditSheetOrThemeViewModel>) {
        self.displayModel = displayModel
        self.editViewModel = editViewModel
    }
    
    func body(content: Content) -> some View {
        content
            .background(getColor() ?? .white)
            .opacity(getOpacity())
    }
    
    func getOpacity() -> Double {
        let transparancy = displayModel?.sheetTheme.backgroundTransparancy ?? editViewModel.item.backgroundTransparancyNumber
        if getColor() != nil {
            let opacity = transparancy > 0.0 ? transparancy : 1.0
            return opacity
        } else {
            return 1.0
        }
    }
    
    func getColor() -> Color? {
        displayModel?.sheetTheme.backgroundColorAsColor ?? editViewModel.item.backgroundColor
    }
    
}
