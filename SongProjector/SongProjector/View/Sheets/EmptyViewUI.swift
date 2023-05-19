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
    
    @ObservedObject private var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    init(editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool) {
        self.editViewModel = editViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        Rectangle().fill(.clear)
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, editModel: editViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier(editViewModel: editViewModel))
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

struct EmptyViewUI_Previews: PreviewProvider {
    @State static var cluster = ClusterCodable.makeDefault()!
    @State static var emptySheet = SheetEmptyCodable.makeDefault()
    @State static var editModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .sheet((cluster, emptySheet), sheetType: .SheetEmpty), isUniversal: false)!)

    static var previews: some View {
        EmptyViewEditUI(editViewModel: editModel, isForExternalDisplay: false)
    }
}
