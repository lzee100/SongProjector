//
//  TitleContentViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

class SheetDisplayViewModel {
    let position: Int
    @Binding var selectedSheet: VSheet?
    let sheet: VSheet
    let sheetTheme: VTheme
    let showSelectionCover: Bool
    
    init(position: Int, selectedSheet: Binding<VSheet?>, sheet: VSheet, sheetTheme: VTheme, showSelectionCover: Bool) {
        self.position = position
        self._selectedSheet = selectedSheet
        self.sheet = sheet
        self.sheetTheme = sheetTheme
        self.showSelectionCover = showSelectionCover
    }
}

struct TitleContentViewUI: View {
    
    let isForExternalDisplay: Bool
    let scaleFactor: CGFloat
    var displayModel: SheetDisplayViewModel?
    
    @ObservedObject private var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    
    init(editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, scaleFactor: CGFloat, isForExternalDisplay: Bool) {
        self.editViewModel = editViewModel
        displayModel = nil
        self.scaleFactor = scaleFactor
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    init(displayModel: SheetDisplayViewModel, scaleFactor: CGFloat, isForExternalDisplay: Bool) {
        self.displayModel = displayModel
        self.editViewModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .newTheme, isUniversal: false)!)
        self.scaleFactor = scaleFactor
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(getTitleAttributedString(text: displayModel?.sheet.title ?? editViewModel.item.title))
                    .modifier(SheetTitleUIModifier(scaleFactor: scaleFactor, displayModel: displayModel, editViewModel: editViewModel, frameWidth: .infinity))
                    .lineLimit(1)
                if editViewModel.item.displayTime {
                    Spacer()
                    Text(getTitleAttributedString(text: Date().time))
                        .modifier(SheetTitleUIModifier(scaleFactor: scaleFactor, displayModel: displayModel, editViewModel: editViewModel))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
           
            Text(getContentAttributedString())
                .modifier(SheetContentModifier(scaleFactor: scaleFactor, multiLine: true, editViewModel: editViewModel))
            Spacer()
        }
        .setBackhgroundImage(isForExternalDisplay: isForExternalDisplay, displayModel: displayModel, editModel: editViewModel)
        .modifier(SheetBackgroundColorAndOpacityModifier(displayModel: displayModel, editViewModel: editViewModel))
        .cornerRadius(10)
        .aspectRatio(16 / 9, contentMode: .fit)
        .ignoresSafeArea()
        .overlay {
            if let displayModel = displayModel, displayModel.selectedSheet?.id != displayModel.sheet.id, displayModel.showSelectionCover {
                Rectangle()
                    .fill(.black.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func getTitleAttributedString(text: String) -> AttributedString {
        let nsAttrString = NSAttributedString(string: text, attributes: displayModel?.sheetTheme.getTitleAttributes(scaleFactor) ?? editViewModel.item.getTitleAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
    
    private func getContentAttributedString() -> AttributedString {
        let nsAttrString = NSAttributedString(string: ((displayModel?.sheet as? VSheetTitleContent)?.content ?? editViewModel.item.sheetContent), attributes: displayModel?.sheetTheme.getLyricsAttributes(scaleFactor) ?? editViewModel.item.getLyricsAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
}

struct TitleContentViewUI_Previews: PreviewProvider {
    
    @State static var songService = makeSongService(true)

    static var previews: some View {
        TitleContentViewUI(displayModel: SheetDisplayViewModel(position: 0, selectedSheet: $songService.selectedSheet, sheet: songService.selectedSheet!, sheetTheme: VTheme(), showSelectionCover: true), scaleFactor: 1, isForExternalDisplay: false)
        .previewInterfaceOrientation(.portrait)
        .previewLayout(.sizeThatFits)
    }
}
