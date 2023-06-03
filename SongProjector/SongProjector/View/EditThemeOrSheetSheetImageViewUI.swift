//
//  EditThemeOrSheetSheetImageViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EditThemeOrSheetSheetImageViewUI: View {
    
    private var scrollViewProxy: ScrollViewProxy?
    @Binding private var isSectionSheetImageExpanded: Bool
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(scrollViewProxy: ScrollViewProxy? = nil, isSectionSheetImageExpanded: Binding<Bool>, sheetViewModel: SheetViewModel) {
        self.scrollViewProxy = scrollViewProxy
        self._isSectionSheetImageExpanded = isSectionSheetImageExpanded
        self.sheetViewModel = sheetViewModel
    }
    
    var body: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionSheetImageExpanded) {
                Divider()
                switch sheetViewModel.sheetEditType {
                case .theme:
                    EmptyView()
                case .custom, .bibleStudy, .lyrics:
                    viewFor(sheetViewModel.sheetModel.sheetType)
                }
            } label: {
                switch sheetViewModel.sheetEditType {
                case .theme:
                    EmptyView()
                case .custom, .bibleStudy, .lyrics:
                    titleViewFor(sheetViewModel.sheetModel.sheetType)
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
            selectedImage: sheetViewModel.sheetModel.getImage(thumb: true)
        ) { image in
            if let image {
                sheetViewModel.sheetModel.setNewSheetImage(image)
            } else {
                sheetViewModel.sheetModel.deleteSheetImage()
            }
        }
    }
}
