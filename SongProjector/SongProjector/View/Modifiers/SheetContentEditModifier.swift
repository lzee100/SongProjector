//
//  SheetContentModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetContentEditModifier: ViewModifier {
    
    let scaleFactor: CGFloat
    let multiLine: Bool
    @ObservedObject var sheetViewModel: SheetViewModel
    private var alignment: TextAlignment {
        switch sheetViewModel.themeModel.theme.contentAlignmentNumber {
        case 0: return .leading
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }

    init(scaleFactor: CGFloat, multiLine: Bool, sheetViewModel: SheetViewModel) {
        self.scaleFactor = scaleFactor
        self.multiLine = multiLine
        self.sheetViewModel = sheetViewModel
    }
    
    func body(content: Content) -> some View {
        if multiLine {
            content
               .padding(EdgeInsets(
                top: getScaledValue(5),
                leading: getScaledValue(10),
                bottom: getScaledValue(10),
                trailing: getScaledValue(10)
            ))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        } else {
            content.padding(EdgeInsets(
                top: getScaledValue(5),
                leading: getScaledValue(10),
                bottom: getScaledValue(10),
                trailing: getScaledValue(10)
            ))
        }
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
}

struct SheetContentDisplayModifier: ViewModifier {
    
    private let scaleFactor: CGFloat
    private let multiLine: Bool
    private let alignment: TextAlignment

    init(scaleFactor: CGFloat, multiLine: Bool, alignment: Int) {
        self.scaleFactor = scaleFactor
        self.multiLine = multiLine
        switch alignment {
        case 0: self.alignment = .leading
        case 1: self.alignment = .center
        case 2: self.alignment = .trailing
        default: self.alignment = .leading
        }
    }
    
    func body(content: Content) -> some View {
        if multiLine {
            content.padding(EdgeInsets(
                top: getScaledValue(5),
                leading: getScaledValue(10),
                bottom: getScaledValue(10),
                trailing: getScaledValue(10)
            ))
            .multilineTextAlignment(alignment)
        } else {
            content.padding(EdgeInsets(
                top: getScaledValue(5),
                leading: getScaledValue(10),
                bottom: getScaledValue(10),
                trailing: getScaledValue(10)
            ))
        }
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
}
