//
//  EmptyViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EmptyViewEditUI: View {
    private let isForExternalDisplay: Bool
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel, isForExternalDisplay: Bool) {
        self.sheetViewModel = sheetViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        Rectangle().fill(.clear)
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, sheetViewModel: sheetViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier(sheetViewModel: sheetViewModel))
            .cornerRadius(10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
    }
}


struct EmptyViewDisplayUI: View {
    
    @ObservedObject private var songServiceModel: WrappedStruct<SongServiceUI>
    private let isForExternalDisplay: Bool
    private let sheet: SheetMetaType
    private let showSelectionCover: Bool
    private var theme: ThemeCodable?
    
    init(serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) {
        _songServiceModel = ObservedObject(initialValue: serviceModel)
        self.isForExternalDisplay = isForExternalDisplay
        self.sheet = sheet
        self.showSelectionCover = showSelectionCover
        self.theme = serviceModel.item.themeFor(sheet: sheet)
    }
    
    var body: some View {
        Rectangle().fill(theme?.sheetBackgroundColor?.color ?? .clear)
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, theme: theme)
            .modifier(SheetBackgroundColorAndOpacityModifier(sheetTheme: theme))
            .cornerRadius(10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
            .overlay {
                if songServiceModel.item.selectedSheetId != sheet.id, showSelectionCover {
                    Rectangle()
                        .fill(.black.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
    }
}
