//
//  SheetTitleUIModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetTitleUIModifier: ViewModifier {
    
    
    private let scaleFactor: CGFloat
    private let frameWidth: CGFloat?
    private var displayModel: SheetDisplayViewModel?
    @ObservedObject var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    private var alignment: Alignment {
        switch editViewModel.item.titleAlignmentNumber {
        case 0: return .leading
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
    
    init(scaleFactor: CGFloat, displayModel: SheetDisplayViewModel? = nil, editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, frameWidth: CGFloat? = nil) {
        self.scaleFactor = scaleFactor
        self.displayModel = displayModel
        self.editViewModel = editViewModel
        self.frameWidth = frameWidth
    }
    
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(
                top: getScaledValue(10),
                leading: getScaledValue(10),
                bottom: getScaledValue(5),
                trailing: getScaledValue(10))
            )
            .frame(maxWidth: frameWidth, alignment: alignment)
            .background(backgroundColor())
    }
    
    private func backgroundColor() -> Color {
        if let displayModel = displayModel {
            if let titleBackgroundColor = displayModel.sheetTheme.backgroundColorTitleAsColor, let title = displayModel.selectedSheet?.title ?? displayModel.sheetTheme.title, title != "" {
                if !displayModel.sheetTheme.allHaveTitle && displayModel.position < 1 {
                    return titleBackgroundColor
                } else if displayModel.sheetTheme.allHaveTitle {
                    return titleBackgroundColor
                } else {
                    return .clear
                }
            } else {
                return .clear
            }
        } else if let hexColor = editViewModel.item.titleBackgroundColor {
            return Color(hex: hexColor)
        } else {
            return .clear
        }
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
}
