//
//  SheetTitleUIModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetTitleEditUIModifier: ViewModifier {
    
    private let scaleFactor: CGFloat
    private let frameWidth: CGFloat?
    @ObservedObject var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    private var alignment: Alignment {
        switch editViewModel.item.titleAlignmentNumber {
        case 0: return .leading
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
    
    init(scaleFactor: CGFloat, editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, frameWidth: CGFloat? = nil) {
        self.scaleFactor = scaleFactor
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
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
}

struct SheetTitleDisplayUIModifier: ViewModifier {
    
    private let scaleFactor: CGFloat
    private let frameWidth: CGFloat?
    private let alignment: Alignment
    
    init(scaleFactor: CGFloat, alignmentNumber: Int, frameWidth: CGFloat? = nil) {
        self.scaleFactor = scaleFactor
        self.frameWidth = frameWidth
        switch alignmentNumber {
        case 0: alignment = .leading
        case 1: alignment = .center
        case 2: alignment = .trailing
        default: alignment = .leading
        }
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
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
}
