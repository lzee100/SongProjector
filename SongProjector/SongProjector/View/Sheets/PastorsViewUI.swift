//
//  PastorsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct PastorsViewEditUI: View {
    private let isForExternalDisplay: Bool
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel, isForExternalDisplay: Bool) {
        self.sheetViewModel = sheetViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                VStack {
                    Spacer()
                    Circle()
                        .stroke(.white, lineWidth: 25)
                        .overlay(
                            pastorsImageView(screenSize: proxy.size)
                        )
                        .frame(maxWidth: proxy.size.height * 0.6)
                    Spacer()
                }
                VStack(spacing: 0) {
                    Spacer()
                    titleView(proxy.size)
                    contentView(proxy.size)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: getScaleFactor(width: proxy.size.width) * 15, bottom: 0, trailing: 0))
            }
            .padding(getScaleFactor(width: proxy.size.width) * 15)
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, sheetViewModel: sheetViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier(sheetViewModel: sheetViewModel))
            .cornerRadius(10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder private func titleView(_ viewSize: CGSize) -> some View {
        Text(getTitleAttributedString(sheetViewModel.title, viewSize: viewSize))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
    }
    
    @ViewBuilder private func contentView(_ viewSize: CGSize) -> some View {
        Text(getContentAttributedString(viewSize: viewSize))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
    }
    
    @ViewBuilder private func pastorsImageView(screenSize: CGSize) -> some View {
        if let uiImage = pastorsImage {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(Circle())
                .padding(EdgeInsets(getScaleFactor(width: screenSize.width) * 3))
        } else {
            Image("PastorsThumb")
                .resizable()
                .clipShape(Circle())
                .opacity(0.3)
                .padding(EdgeInsets(getScaleFactor(width: screenSize.width) * 3))
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
    
    private var pastorsImage: UIImage? {
        sheetViewModel.sheetModel.getImage(thumb: !isForExternalDisplay)
    }
}



struct PastorsViewDisplayUI: View {
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
        self.theme = serviceModel.item.themeFor(sheet: sheet)
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                VStack {
                    Spacer()
                    Circle()
                        .stroke(.white, lineWidth: 25)
                        .overlay(
                            pastorsImageView(screenSize: proxy.size)
                        )
                        .frame(maxWidth: proxy.size.height * 0.6)
                    Spacer()
                }
                VStack(spacing: 0) {
                    Spacer()
                    titleView(proxy.size)
                    contentView(proxy.size)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: getScaleFactor(width: proxy.size.width) * 15, bottom: 0, trailing: 0))
            }
            .padding(getScaleFactor(width: proxy.size.width) * 15)
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
    
    @ViewBuilder private func titleView(_ viewSize: CGSize) -> some View {
        
        if let title = sheet.title {
            Text(getTitleAttributedString(title, viewSize: viewSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder private func contentView(_ viewSize: CGSize) -> some View {
        Text(getContentAttributedString(viewSize: viewSize))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
    }
    
    @ViewBuilder private func pastorsImageView(screenSize: CGSize) -> some View {
        if let uiImage = pastorsImage {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(Circle())
                .padding(EdgeInsets(getScaleFactor(width: screenSize.width) * 3))
        } else {
            Image("PastorsThumb")
                .resizable()
                .clipShape(Circle())
                .opacity(0.3)
                .padding(EdgeInsets(getScaleFactor(width: screenSize.width) * 3))
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
    
    private var pastorsImage: UIImage? {
        isForExternalDisplay ? sheet.sheetImage : sheet.sheetImageThumbnail
    }
}
