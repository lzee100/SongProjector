//
//  EditThemeOrSheetSheetImageViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EditThemeOrSheetSheetImageViewUI: View {
    
    var scrollViewProxy: ScrollViewProxy? = nil
    @Binding var isSectionSheetImageExpanded: Bool
    @ObservedObject var editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    var body: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionSheetImageExpanded) {
                Divider()
                switch editSheetOrThemeModel.item.editMode {
                case .newTheme, .persistedTheme:
                    EmptyView()
                case .newSheet(_ , let type):
                    viewFor(type)
                case .persistedSheet(_, let type):
                    viewFor(type)
                }
            } label: {
                switch editSheetOrThemeModel.item.editMode {
                case .newTheme, .persistedTheme:
                    EmptyView()
                case .newSheet(_ , let type):
                    titleViewFor(type)
                case .persistedSheet(_, let type):
                    titleViewFor(type)
                }
            }
            .accentColor(.black.opacity(0.8))
        }
        .onChange(of: isSectionSheetImageExpanded) { newValue in
            withAnimation(.linear.delay(0.3)) {
                scrollViewProxy?.scrollTo(4, anchor: .bottom)
            }
        }
    }
    
    @ViewBuilder func viewFor(_ sheetType: SheetType) -> some View {
        switch sheetType {
        case .SheetTitleImage, .SheetPastors:
            photoPickerView.id(4)
        case .SheetTitleContent, .SheetEmpty, .SheetActivities, .SheetSplit:
            EmptyView()
        }
    }
    
    @ViewBuilder func titleViewFor(_ sheetType: SheetType) -> some View {
        switch sheetType {
        case .SheetTitleImage:
            Text(AppText.NewSheetTitleImage.title)
                .styleAsSection
        case .SheetPastors:
            Text(AppText.NewSheetTitleImage.title)
                .styleAsSection
        case .SheetTitleContent, .SheetEmpty, .SheetActivities, .SheetSplit:
            EmptyView()
        }
    }
    
    @ViewBuilder private var photoPickerView: some View {
        LabelPhotoPickerViewUI(
            label: AppText.NewSheetTitleImage.descriptionImage,
            selectedImageData: editSheetOrThemeModel.item.sheetImageThumbData,
            selectedImage: $editSheetOrThemeModel.item.newSelectedSheetImage
        ) { image in
            if image == nil {
                editSheetOrThemeModel.item.deleteSheetImage()
            }
        }
    }
}

struct EditThemeOrSheetSheetImageViewUI_Previews: PreviewProvider {
    @State static var imageSheet = SheetTitleImageCodable(id: "", userUID: "", title: "Title image sheet", createdAt: Date(), updatedAt: Date(), deleteDate: nil, isTemp: false, rootDeleteDate: nil, isEmptySheet: false, position: 0, time: 0, hasTheme: ThemeCodable.makeDefault(), content: "Content image sheet", hasTitle: false, imageBorderColor: nil, imageBorderSize: 0, imageContentMode: 0, imageHasBorder: false, imagePath: nil, thumbnailPath: nil, imagePathAWS: nil)
    @State static var editViewModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .persistedSheet(imageSheet, sheetType: .SheetTitleImage), isUniversal: false, image: UIImage(named: "Pio-Sebastiaan-en-Marilou.jpg"))!)
    @State static var isSectionExpanded = true
    static var previews: some View {
        EditThemeOrSheetSheetImageViewUI(isSectionSheetImageExpanded: $isSectionExpanded, editSheetOrThemeModel: editViewModel)
    }

}
