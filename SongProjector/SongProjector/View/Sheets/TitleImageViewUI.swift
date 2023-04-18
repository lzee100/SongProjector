//
//  TitleImageViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TitleImageViewUI: View {
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
            
            if !hasNoTitle {
                HStack {
                    Text(getTitleAttributedString(titleString))
                        .modifier(SheetTitleUIModifier(scaleFactor: scaleFactor, displayModel: displayModel, editViewModel: editViewModel, frameWidth: .infinity))
                        .lineLimit(1)
                    if editViewModel.item.displayTime {
                        Spacer()
                        Text(getTitleAttributedString(Date().time))
                            .modifier(SheetTitleUIModifier(scaleFactor: scaleFactor, displayModel: displayModel, editViewModel: editViewModel))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            if contentString.count > 0 {
                HStack{
                    if [1, 2].contains(editViewModel.item.contentAlignmentNumber.intValue) {
                        Spacer()
                    }
                    Text(getContentAttributedString())
                        .modifier(SheetContentModifier(scaleFactor: scaleFactor, multiLine: false, editViewModel: editViewModel))
                    if [0, 1].contains(editViewModel.item.contentAlignmentNumber.intValue) {
                        Spacer()
                    }
                }
            }
            if let uiImage = editViewModel.item.newSelectedSheetImage ?? editViewModel.item.sheetImagePath?.loadImage() {
                HStack {
                    Spacer()
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(uiImage.size, contentMode: .fit)
                    Spacer()
                }
                .padding(EdgeInsets(top: hasNoTitle && contentString.count == 0 ? 15 : 0, leading: 0, bottom: 15, trailing: 0))
            } else {
                Spacer()
            }
        }
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
}

struct TitleImageViewUI_Previews: PreviewProvider {
    @State static var imageSheet = SheetTitleImageCodable(id: "", userUID: "", title: "Title image sheet", createdAt: Date(), updatedAt: Date(), deleteDate: nil, isTemp: false, rootDeleteDate: nil, isEmptySheet: false, position: 0, time: 0, hasTheme: ThemeCodable.makeDefault(), content: "Content image sheet", hasTitle: false, imageBorderColor: nil, imageBorderSize: 0, imageContentMode: 0, imageHasBorder: false, imagePath: nil, thumbnailPath: nil, imagePathAWS: nil)
    @State static var editModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .persistedSheet(imageSheet, sheetType: .SheetTitleImage), isUniversal: false, image: UIImage(named: "Pio-Sebastiaan-en-Marilou.jpg"))!)
    static var previews: some View {
        TitleImageViewUI(editViewModel: editModel, scaleFactor: 1, isForExternalDisplay: false)
            .previewInterfaceOrientation(.portrait)
            .previewLayout(.sizeThatFits)
    }
}
