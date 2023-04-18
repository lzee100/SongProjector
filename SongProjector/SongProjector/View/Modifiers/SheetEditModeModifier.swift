//
//  SheetEditModeModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetEditModeModifier: ViewModifier {
            
    var sheetsize: CGSize
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(
                width: Self.getSheetSizeFor(sheetsize).width == nil ? getSizeWith(height: Self.getSheetSizeFor(sheetsize).height).width  : Self.getSheetSizeFor(sheetsize).width!,
                height: Self.getSheetSizeFor(sheetsize).height
            )
            .cornerRadius(10)
            .shadow(radius: 2)
    }
    
    static func getScaleFactor(_ container: CGSize) -> CGFloat {
        ChurchBeam.getScaleFactor(width: getSheetSizeFor(container).width == nil ? getSizeWith(height: getSheetSizeFor(container).height).width : getSheetSizeFor(container).width!)
    }
    static func getSheetSizeFor(_ containerSize: CGSize) -> (width: CGFloat?, height: CGFloat) {
        (width: containerSize.width > containerSize.height ? min(containerSize.width, 500) : nil,
            height: getSizeWith(width: containerSize.width > containerSize.height ? min(containerSize.width, 500) : containerSize.width).height
        )
    }
}

extension View {
    
    func modifySheetInEditMode(for sheetSize: CGSize) -> some View {
        self.modifier(SheetEditModeModifier(sheetsize: sheetSize))
    }
}
