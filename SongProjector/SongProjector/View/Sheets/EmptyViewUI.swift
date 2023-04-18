//
//  EmptyViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EmptyViewUI: View {
    let isForExternalDisplay: Bool
    var displayModel: SheetDisplayViewModel?
    
    @ObservedObject private var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    
    init(editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool) {
        self.editViewModel = editViewModel
        displayModel = nil
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    init(displayModel: SheetDisplayViewModel, isForExternalDisplay: Bool) {
        self.displayModel = displayModel
        self.editViewModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .newTheme, isUniversal: false)!)
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        Rectangle().fill(.clear)
            .setBackhgroundImage(isForExternalDisplay: isForExternalDisplay, displayModel: displayModel, editModel: editViewModel)
            .modifier(SheetBackgroundColorAndOpacityModifier(displayModel: displayModel, editViewModel: editViewModel))
            .cornerRadius(10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
            .overlay {
                if let displayModel = displayModel, displayModel.selectedSheet?.id != displayModel.sheet.id, displayModel.showSelectionCover {
                    Rectangle()
                        .fill(.black.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
    }
}

struct EmptyViewUI_Previews: PreviewProvider {
    @State static var emptySheet = SheetEmptyCodable.makeDefault()
    @State static var editModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .persistedSheet(emptySheet, sheetType: .SheetEmpty), isUniversal: false)!)

    static var previews: some View {
        EmptyViewUI(editViewModel: editModel, isForExternalDisplay: false)
    }
}
