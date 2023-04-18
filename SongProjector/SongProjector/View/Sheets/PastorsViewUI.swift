//
//  PastorsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct PastorsViewUI: View {
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
                    titleView
                    contentView
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: getScaleFactor(width: proxy.size.width) * 15, bottom: 0, trailing: 0))
            }
            .padding(getScaleFactor(width: proxy.size.width) * 15)
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
    
    @ViewBuilder private var titleView: some View {
        Text(getTitleAttributedString(titleString))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
    }
    
    @ViewBuilder private var contentView: some View {
        Text(getContentAttributedString())
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
            EmptyView()
        }
    }
    
    private func getTitleAttributedString(_ value: String) -> AttributedString {
        let nsAttrString = NSAttributedString(string: value, attributes: displayModel?.sheetTheme.getTitleAttributes(scaleFactor) ?? editViewModel.item.getTitleAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
    
    private func getContentAttributedString() -> AttributedString {
        let nsAttrString = NSAttributedString(string: contentString, attributes: displayModel?.sheetTheme.getLyricsAttributes(scaleFactor) ?? editViewModel.item.getLyricsAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
    
    private var titleString: String {
        displayModel?.sheet.title ?? editViewModel.item.title
    }
    
    private var hasNoTitle: Bool {
        titleString.count == 0 && !editViewModel.item.displayTime
    }
    
    private var contentString: String {
        (displayModel?.sheet as? VSheetTitleContent)?.content ?? editViewModel.item.sheetContent
    }
    
    private var pastorsImage: UIImage? {
        var scaledImage: UIImage? {
            isForExternalDisplay ? editViewModel.item.sheetImagePath?.loadImage() : editViewModel.item.sheetImagePathThumb?.loadImage()
        }
        return editViewModel.item.newSelectedSheetImage ?? scaledImage
    }
}

struct PastorsViewUI_Previews: PreviewProvider {
    @State static var pastorsSheet = SheetPastorsCodable.makeDefault()
    @State static var editModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .persistedSheet(pastorsSheet, sheetType: .SheetPastors), isUniversal: false, image: UIImage(named: "Pio-Sebastiaan-en-Marilou.jpg"))!)

    static var previews: some View {
        PastorsViewUI(editViewModel: editModel, scaleFactor: 3, isForExternalDisplay: false)
    }
}
