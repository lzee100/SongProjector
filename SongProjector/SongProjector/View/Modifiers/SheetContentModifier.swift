//
//  SheetContentModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetContentModifier: ViewModifier {
    
    let scaleFactor: CGFloat
    let multiLine: Bool
    @ObservedObject var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    private var alignment: TextAlignment {
        switch editViewModel.item.contentAlignmentNumber {
        case 0: return .leading
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }

    init(scaleFactor: CGFloat, multiLine: Bool, editViewModel: WrappedStruct<EditSheetOrThemeViewModel>) {
        self.scaleFactor = scaleFactor
        self.multiLine = multiLine
        self.editViewModel = editViewModel
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
            .frame(maxWidth: .infinity)
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
