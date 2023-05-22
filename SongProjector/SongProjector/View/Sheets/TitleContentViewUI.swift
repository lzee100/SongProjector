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

struct TitleContentViewDisplayUI_Previews: PreviewProvider {
    @State static var cluster = ClusterCodable.makeDefault()!
    @State static var songServiceModel = WrappedStruct(withItem: SongServiceUI(songs: [SongObjectUI(cluster: .makeDefault()!)]))
    @State static var imageSheet = SheetTitleImageCodable.makeDefault()
    @State static var editModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .sheet((cluster, imageSheet), sheetType: .SheetTitleImage), isUniversal: false, image: UIImage(named: "Pio-Sebastiaan-en-Marilou.jpg"))!)
    
    static var previews: some View {
        TitleContentViewDisplayUI(songServiceModel: songServiceModel, sheet: SheetTitleImageCodable.makeDefault(), isForExternalDisplay: false, showSelectionCover: false)
            .previewInterfaceOrientation(.portrait)
            .previewLayout(.sizeThatFits)
    }
}


struct TitleContentViewEditUI: View {
    
    @State var sheetSize: CGSize

    @ObservedObject private var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    private let isForExternalDisplay: Bool
    
    init(editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, sheetSize: CGSize, isForExternalDisplay: Bool) {
        self.sheetSize = sheetSize
        self.editViewModel = editViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
            VStack(spacing: 0) {
                
                HStack {
                    Text(getTitleAttributedString(text: editViewModel.item.title, viewSize: sheetSize))
                        .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: sheetSize.width), editViewModel: editViewModel, frameWidth: .infinity))
                        .lineLimit(1)
                    if editViewModel.item.displayTime {
                        Spacer()
                        Text(getTitleAttributedString(text: Date().time, viewSize: sheetSize))
                            .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: sheetSize.width), editViewModel: editViewModel, frameWidth: .infinity))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                HStack{
                    if [1, 2].contains(editViewModel.item.theme.contentAlignmentNumber) {
                        Spacer()
                    }
                    Text(getContentAttributedString(viewSize: sheetSize))
                        .modifier(SheetContentDisplayModifier(
                            scaleFactor: getScaleFactor(width: sheetSize.width),
                            multiLine: true,
                            alignment: editViewModel.item.theme.contentAlignmentNumber.intValue
                        ))
                    if [0, 1].contains(editViewModel.item.theme.contentAlignmentNumber) {
                        Spacer()
                    }
                }
                Spacer()
            }
            .observeViewSize()
            .onPreferenceChange(SizePreferenceKey.self, perform: { size in
                sheetSize = size
            })
            .setBackgroundImage(isForExternalDisplay: false, editModel: editViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier(editViewModel: editViewModel))
            .cornerRadius(10)
            .aspectRatio(16 / 9, contentMode: .fit)
            .ignoresSafeArea()
    }
    
    private func getTitleAttributedString(text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: editViewModel.item.getTitleAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private func getContentAttributedString(viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: editViewModel.item.sheetContent,
            attributes: editViewModel.item.getLyricsAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
}

struct SheetBackgroundColorAndOpacityEditModifier: ViewModifier {
    
    @ObservedObject private var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    init(editViewModel: WrappedStruct<EditSheetOrThemeViewModel>) {
        self.editViewModel = editViewModel
    }
    
    func body(content: Content) -> some View {
        content
            .background(getColor() ?? .white)
            .opacity(getOpacity())
    }
    
    func getOpacity() -> Double {
        let transparancy = editViewModel.item.backgroundTransparancyNumber
        if getColor() == nil || (editViewModel.item.imagePath == nil && editViewModel.item.newSelectedThemeImage == nil) {
            return 1.0
        }
        return transparancy
    }
    
    func getColor() -> Color? {
        editViewModel.item.backgroundColor
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
                    
                    HStack{
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
