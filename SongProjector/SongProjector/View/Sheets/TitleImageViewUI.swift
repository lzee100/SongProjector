//
//  TitleImageViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TitleImageEditViewUI: View {
    private let isForExternalDisplay: Bool
    
    @ObservedObject private var editModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    init(editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool) {
        self.editModel = editViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                if !hasNoTitle {
                    HStack {
                        Text(getTitleAttributedString(editModel.item.title, viewSize: proxy.size))
                            .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), editViewModel: editModel, frameWidth: .infinity))
                            .lineLimit(1)
                        if editModel.item.theme.displayTime {
                            Spacer()
                            Text(getTitleAttributedString(Date().time, viewSize: proxy.size))
                                .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), editViewModel: editModel))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                if editModel.item.sheetContent.count > 0 {
                    HStack{
                        if [1, 2].contains(editModel.item.contentAlignmentNumber.intValue) {
                            Spacer()
                        }
                        Text(getContentAttributedString(viewSize: proxy.size))
                            .modifier(SheetContentEditModifier(scaleFactor: getScaleFactor(width: proxy.size.width), multiLine: false, editViewModel: editModel))
                        if [0, 1].contains(editModel.item.contentAlignmentNumber.intValue) {
                            Spacer()
                        }
                    }
                }
                if let uiImage = editModel.item.newSelectedSheetImage ?? editModel.item.sheetImagePath?.loadImage() {
                    HStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(uiImage.size, contentMode: .fit)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: hasNoTitle && editModel.item.sheetContent.count == 0 ? 15 : 0, leading: 0, bottom: 15, trailing: 0))
                } else {
                    Spacer()
                }
            }
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, editModel: editModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier(editViewModel: editModel))
            .cornerRadius(10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
        }
    }
    
    private func getTitleAttributedString(_ text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: editModel.item.getTitleAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private func getContentAttributedString(viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: editModel.item.sheetContent,
            attributes: editModel.item.getLyricsAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private var hasNoTitle: Bool {
        editModel.item.title.count == 0 && !editModel.item.displayTime
    }
    
}

struct TitleImageViewUI_Previews: PreviewProvider {
    @State static var cluster = ClusterCodable.makeDefault()!
    @State static var imageSheet = SheetTitleImageCodable.makeDefault()
    @State static var editModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .sheet((cluster, imageSheet), sheetType: .SheetTitleImage), isUniversal: false, isBibleVers: false)!)
    static var previews: some View {
        TitleImageEditViewUI(editViewModel: editModel, isForExternalDisplay: false)
            .previewInterfaceOrientation(.portrait)
            .previewLayout(.sizeThatFits)
    }
}

struct TitleImageDisplayViewUI: View {
    
    private let isForExternalDisplay: Bool
    @ObservedObject private var songServiceModel: WrappedStruct<SongServiceUI>
    private let sheet: SheetMetaType
    private let showSelectionCover: Bool
    private var theme: ThemeCodable?
    
    init(serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) {
        _songServiceModel = ObservedObject(initialValue: serviceModel)
        self.sheet = sheet
        self.isForExternalDisplay = isForExternalDisplay
        self.showSelectionCover = showSelectionCover
        self.theme = songServiceModel.item.themeFor(sheet: sheet)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                if !hasNoTitle {
                    HStack {
                        Text(getTitleAttributedString(songServiceModel.item.sheetTitleFor(sheet: sheet) ?? "", viewSize: proxy.size))
                            .modifier(SheetTitleDisplayUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), alignmentNumber: theme?.titleAlignmentNumber.intValue ?? 0, frameWidth: .infinity))
                            .lineLimit(1)
                        if theme?.displayTime ?? false {
                            Spacer()
                            Text(getTitleAttributedString(Date().time, viewSize: proxy.size))
                                .modifier(SheetTitleDisplayUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), alignmentNumber: theme?.titleAlignmentNumber.intValue ?? 0))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                if sheet.sheetContent?.count ?? 0 > 0 {
                    HStack{
                        if [1, 2].contains(theme?.contentAlignmentNumber) {
                            Spacer()
                        }
                        Text(getContentAttributedString(viewSize: proxy.size))
                            .modifier(SheetContentDisplayModifier(scaleFactor: getScaleFactor(width: proxy.size.width), multiLine: true, alignment: theme?.contentAlignmentNumber.intValue ?? 0))
                        if [0, 1].contains(theme?.contentAlignmentNumber) {
                            Spacer()
                        }
                    }
                }
                if let uiImage = isForExternalDisplay ? sheet.sheetImagePath?.loadImage() : sheet.sheetImageThumbnailPath?.loadImage() {
                    HStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(uiImage.size, contentMode: .fit)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: hasNoTitle && sheet.sheetContent?.count ?? 0 == 0 ? 15 : 0, leading: 0, bottom: 15, trailing: 0))
                } else {
                    Spacer()
                }
            }
            .setBackgroundImage(isForExternalDisplay: false, theme: theme)
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
    
    private func getTitleAttributedString(_ text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: theme?.getTitleAttributes(getScaleFactor(width: viewSize.width)) ?? [:]
        ))
    }
    
    private func getContentAttributedString(viewSize: CGSize) -> AttributedString {
        guard let content = sheet.sheetContent else { return AttributedString() }
        return AttributedString(NSAttributedString(
            string: content,
            attributes: theme?.getLyricsAttributes(getScaleFactor(width: viewSize.width)) ?? [:]
        ))
    }
    
    private var hasNoTitle: Bool {
        (songServiceModel.item.sheetTitleFor(sheet: sheet) ?? "").count == 0 && !(theme?.displayTime ?? true)
    }
}
