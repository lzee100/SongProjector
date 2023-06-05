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
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel, isForExternalDisplay: Bool) {
        self.sheetViewModel = sheetViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                if !hasNoTitle {
                    HStack {
                        Text(getTitleAttributedString(sheetViewModel.title, viewSize: proxy.size))
                            .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel: sheetViewModel, frameWidth: .infinity))
                            .lineLimit(1)
                        if sheetViewModel.themeModel.theme.displayTime {
                            Spacer()
                            Text(getTitleAttributedString(Date().time, viewSize: proxy.size))
                                .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel: sheetViewModel))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                if sheetViewModel.sheetModel.content.count > 0 {
                    HStack{
                        if [1, 2].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber.intValue) {
                            Spacer()
                        }
                        Text(getContentAttributedString(viewSize: proxy.size))
                            .modifier(SheetContentEditModifier(scaleFactor: getScaleFactor(width: proxy.size.width), multiLine: false, sheetViewModel: sheetViewModel))
                        if [0, 1].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber.intValue) {
                            Spacer()
                        }
                    }
                }
                if let uiImage = sheetViewModel.sheetModel.getImage(thumb: true) {
                    HStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(uiImage.size, contentMode: .fit)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: hasNoTitle && sheetViewModel.sheetModel.content.count == 0 ? 15 : 0, leading: 0, bottom: 15, trailing: 0))
                } else {
                    Spacer()
                }
            }
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, sheetViewModel: sheetViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier(sheetViewModel: sheetViewModel))
            .cornerRadius(isForExternalDisplay ? 0 : 10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
        }
    }
    
    private func getTitleAttributedString(_ text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: sheetViewModel.themeModel.theme.getTitleAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private func getContentAttributedString(viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: sheetViewModel.sheetModel.content,
            attributes: sheetViewModel.themeModel.theme.getLyricsAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private var hasNoTitle: Bool {
        sheetViewModel.title.count == 0 && !sheetViewModel.themeModel.theme.displayTime
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
