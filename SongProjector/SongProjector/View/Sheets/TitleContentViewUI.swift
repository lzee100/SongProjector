//
//  TitleContentViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

protocol BodyView: View where Body: View {
    
    var content: Body { get }

}

extension BodyView {
    @ViewBuilder
    var body: some View {
        content
    }
}

struct PPP<T: BodyView>: View {
    
    private let content: T
    
    init(content: T) {
        self.content = content
    }
    
    @ViewBuilder
    var body: some View {
        content
    }
}

struct TitleContentViewUI<T: BodyView>: View {
    
    private let content: T
    
    init(content: T) {
        self.content = content
    }
    
    @ViewBuilder
    var body: some View {
        content
    }
}

struct TitleContentViewEditUI: View {
    
    @State var sheetSize: CGSize = .zero

    @ObservedObject private var sheetViewModel: SheetViewModel
    
    private let isForExternalDisplay: Bool
    
    init(sheetViewModel: SheetViewModel, isForExternalDisplay: Bool) {
        self.sheetViewModel = sheetViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
            VStack(spacing: 0) {
                
                HStack {
                    Text(getTitleAttributedString(text: sheetViewModel.title, viewSize: sheetSize))
                        .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: sheetSize.width), sheetViewModel: sheetViewModel, frameWidth: .infinity))
                        .lineLimit(1)
                    if sheetViewModel.themeModel.theme.displayTime {
                        Spacer()
                        Text(getTitleAttributedString(text: Date().time, viewSize: sheetSize))
                            .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: sheetSize.width), sheetViewModel: sheetViewModel, frameWidth: .infinity))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    if [1, 2].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber) {
                        Spacer()
                    }
                    Text(getContentAttributedString(viewSize: sheetSize))
                        .modifier(SheetContentDisplayModifier(
                            scaleFactor: getScaleFactor(width: sheetSize.width),
                            multiLine: true,
                            alignment: sheetViewModel.themeModel.theme.contentAlignmentNumber.intValue
                        ))
                    if [0, 1].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber) {
                        Spacer()
                    }
                }
                Spacer()
            }
            .observeViewSize()
            .onPreferenceChange(SizePreferenceKey.self, perform: { size in
                sheetSize = size
            })
            .setBackgroundImage(isForExternalDisplay: false, sheetViewModel: sheetViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier2(sheetViewModel: sheetViewModel))
            .cornerRadius(10)
            .aspectRatio(16 / 9, contentMode: .fit)
            .ignoresSafeArea()
    }
    
    private func getTitleAttributedString(text: String, viewSize: CGSize) -> AttributedString {
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
}

struct SheetBackgroundColorAndOpacityEditModifier: ViewModifier {
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel) {
        self.sheetViewModel = sheetViewModel
    }
    
    func body(content: Content) -> some View {
        content
            .background(getColor() ?? .white)
            .opacity(getOpacity())
    }
    
    func getOpacity() -> Double {
        let transparancy = sheetViewModel.themeModel.theme.backgroundTransparancyNumber
        if getColor() == nil || (sheetViewModel.themeModel.getImage(thumb: true) == nil) {
            return 1.0
        }
        return transparancy
    }
    
    func getColor() -> Color? {
        sheetViewModel.themeModel.theme.backgroundColor?.color
    }
    
}

struct SheetBackgroundColorAndOpacityEditModifier2: ViewModifier {
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel) {
        self.sheetViewModel = sheetViewModel
    }
    
    func body(content: Content) -> some View {
        content
            .background(getColor() ?? .white)
            .opacity(getOpacity())
    }
    
    func getOpacity() -> Double {
        let transparancy = sheetViewModel.themeModel.theme.backgroundTransparancyNumber
        if getColor() == nil || (sheetViewModel.themeModel.theme.imagePath == nil && sheetViewModel.themeModel.newSelectedImage == nil) {
            return 1.0
        }
        return transparancy
    }
    
    func getColor() -> Color? {
        sheetViewModel.themeModel.theme.backgroundColor?.color
    }
    
}




struct TitleContentViewDisplayUI: View {
    
    private let isForExternalDisplay: Bool
    @ObservedObject private var songServiceModel: WrappedStruct<SongServiceUI>
    private let sheet: SheetMetaType
    private let showSelectionCover: Bool
    private let theme: ThemeCodable?
    private var titleAlignmentNumber: Int {
        theme?.titleAlignmentNumber.intValue ?? 0
    }
    
    private var contentAlignmentNumber: Int {
        theme?.contentAlignmentNumber.intValue ?? 0
    }
    
    init(songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) {
        self.songServiceModel = songServiceModel
        self.sheet = sheet
        self.isForExternalDisplay = isForExternalDisplay
        self.showSelectionCover = showSelectionCover
        self.theme = songServiceModel.item.themeFor(sheet: sheet)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                HStack {
                    Text(getTitleAttributedString(text: (songServiceModel.item.sheetTitleFor(sheet: sheet) ?? "") + "\(sheet.position)", viewSize: proxy.size))
                        .modifier(SheetTitleDisplayUIModifier(
                            scaleFactor: getScaleFactor(width: proxy.size.width),
                            alignmentNumber: titleAlignmentNumber,
                            frameWidth: .infinity
                        ))
                        .lineLimit(1)
                    if theme?.displayTime ?? false {
                        Spacer()
                        Text(getTitleAttributedString(text: Date().time, viewSize: proxy.size))
                            .modifier(SheetTitleDisplayUIModifier(
                                scaleFactor: getScaleFactor(width: proxy.size.width),
                                alignmentNumber: titleAlignmentNumber,
                                frameWidth: .infinity
                            ))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                if let content = getContentAttributedString(viewSize: proxy.size) {
                    
                    HStack(spacing: 0) {
                        if [1, 2].contains(theme?.contentAlignmentNumber) {
                            Spacer()
                        }
                        Text(content)
                            .modifier(SheetContentDisplayModifier(
                                scaleFactor: getScaleFactor(width: proxy.size.width),
                                multiLine: true,
                                alignment: contentAlignmentNumber
                            ))
                        if [0, 1].contains(theme?.contentAlignmentNumber) {
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            .setBackgroundImage(isForExternalDisplay: false, theme: theme)
            .modifier(SheetBackgroundColorAndOpacityModifier(sheetTheme: theme))
            .background(theme?.backgroundColor?.color ?? .clear)
            .opacity(theme?.backgroundTransparancy ?? 1)
            .cornerRadius(10)
            .aspectRatio(16 / 9, contentMode: .fit)
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
    
    private func getTitleAttributedString(text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: theme?.getTitleAttributes(getScaleFactor(width: viewSize.width)) ?? [:]
        ))
    }
    
    private func getContentAttributedString(viewSize: CGSize) -> AttributedString? {
        guard let content = sheet.sheetContent else { return nil }
        return AttributedString(NSAttributedString(
            string: content,
            attributes: theme?.getLyricsAttributes(getScaleFactor(width: viewSize.width)) ?? [:]
        ))
    }
}
