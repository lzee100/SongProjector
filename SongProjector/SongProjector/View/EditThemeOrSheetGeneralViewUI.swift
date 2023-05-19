//
//  EditThemeOrSheetGeneralViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EditThemeOrSheetGeneralViewUI: View {
    
    var scrollViewProxy: ScrollViewProxy? = nil
    @Binding var isSectionGeneralExpanded: Bool
    @ObservedObject var editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>

    var body: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionGeneralExpanded) {
                Divider()
                switch editSheetOrThemeModel.item.editMode {
                case .theme:
                    VStack() {
                        titleInputView
                        Divider()
                        asThemeInputView
                        Divider()
                        displayEmptySheetAndAsFirst
                            .id(1)
                        Divider()
                        allSheetsHaveTitle
                        Divider()
                        backgroundColorAndImageView
                        dividerAndDisplayTime
                    }
                case .sheet(_, let type):
                    viewForSheet(type)
                }
            } label: {
                Text(AppText.NewTheme.sectionGeneral)
                    .styleAsSection
            }
            .accentColor(.black.opacity(0.8))
        }
        .onChange(of: isSectionGeneralExpanded) { newValue in
            withAnimation(.linear.delay(0.3)) {
                scrollViewProxy?.scrollTo(1, anchor: .bottom)
            }
        }
    }
    
    @ViewBuilder var backgroundColorAndImageView: some View {
        VStack {
            LabelColorPickerViewUI(label: AppText.NewTheme.descriptionBackgroundColor, defaultColor: .white, selectedColor: $editSheetOrThemeModel.item.backgroundColor)
            
            Divider()
            
            LabelPhotoPickerViewUI(label: AppText.NewTheme.backgroundImage, selectedImageData: editSheetOrThemeModel.item.getThemeImageData(thumb: true), selectedImage: $editSheetOrThemeModel.item.newSelectedThemeImage) { image in
                if image == nil {
                    editSheetOrThemeModel.item.deleteThemeImage()
                    editSheetOrThemeModel.item.backgroundTransparancyNumber = 1.0
                }
            }
            
            if editSheetOrThemeModel.item.getThemeImage(thumb: true) != nil {
                Slider(value: $editSheetOrThemeModel.item.backgroundTransparancyNumber, in: 0.0...1.0) {
                    Text(AppText.NewTheme.descriptionBackgroundTransparency)
                        .styleAs(font: .xNormal)
                }
                .accentColor(Color(themeHighlighted))
            }
        }
    }
    
    @ViewBuilder var titleInputView: some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: editSheetOrThemeModel.item.editMode.isSheet ? AppText.NewSheetTitleImage.descriptionTitle : AppText.NewTheme.descriptionTitle,
                placeholder: AppText.NewTheme.descriptionTitlePlaceholder,
                characterLimit: 80,
                text: $editSheetOrThemeModel.item.title
            )
        )
    }
    
    @ViewBuilder var ContentInputView: some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: AppText.NewSheetTitleImage.descriptionContent,
                placeholder: AppText.NewTheme.sampleLyrics,
                characterLimit: 400,
                text: $editSheetOrThemeModel.item.sheetContent
            )
        )
    }
    
    @ViewBuilder var ContentInputLeftView: some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: AppText.NewSheetTitleImage.descriptionTextLeft,
                placeholder: AppText.NewTheme.sampleLyrics,
                characterLimit: 400,
                text: $editSheetOrThemeModel.item.sheetContent
            )
        )
    }
    
    @ViewBuilder var ContentInputRightView: some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: AppText.NewSheetTitleImage.descriptionTextRight,
                placeholder: AppText.NewTheme.sampleLyrics,
                characterLimit: 400,
                text: $editSheetOrThemeModel.item.sheetContentRight
            )
        )
    }
    
    @ViewBuilder var asThemeInputView: some View {
        PickerViewUI(label: AppText.NewTheme.descriptionAsTheme, pickerValues: editSheetOrThemeModel.item.getPersistedThemes()) { value in
            if let theme = value.value as? Theme {
                editSheetOrThemeModel.item.styleAsTheme(theme)
            }
        }
    }
    
    @ViewBuilder var displayEmptySheetAndAsFirst: some View {
        ToggleViewUI(label: AppText.NewTheme.descriptionHasEmptySheet, isOn: $editSheetOrThemeModel.item.hasEmptySheet)
        
                if editSheetOrThemeModel.item.hasEmptySheet {
                    Divider()
                    ToggleViewUI(label: AppText.NewTheme.descriptionPositionEmptySheet, isOn: $editSheetOrThemeModel.item.isEmptySheetFirst)
                }
    }
    
    @ViewBuilder var allSheetsHaveTitle: some View {
        ToggleViewUI(label: AppText.NewTheme.descriptionAllTitle, isOn: $editSheetOrThemeModel.item.allHaveTitle)
    }
    
    @ViewBuilder var dividerAndDisplayTime: some View {
        VStack {
            Divider()
            ToggleViewUI(label: AppText.NewTheme.descriptionDisplayTime, isOn: $editSheetOrThemeModel.item.displayTime)
        }
    }
    
    @ViewBuilder var titleContentInputAndBackgroundView: some View {
        VStack {
            titleInputView
            Divider()
            ContentInputView
            Divider()
            asThemeInputView
            Divider()
            backgroundColorAndImageView
        }
    }
    
    @ViewBuilder var titleInputAndBackgroundView: some View {
        VStack {
            titleInputView
            Divider()
            asThemeInputView
            Divider()
            backgroundColorAndImageView
        }
    }
    
    @ViewBuilder func viewForSheet(_ type: SheetType) -> some View {
        switch type {
        case .SheetTitleContent:
            titleContentInputAndBackgroundView
        case .SheetTitleImage:
            titleContentInputAndBackgroundView
        case .SheetEmpty:
            titleInputAndBackgroundView
        case .SheetPastors:
            titleContentInputAndBackgroundView
        case .SheetSplit:
            VStack {
                titleInputView
                Divider()
                ContentInputLeftView
                Divider()
                ContentInputRightView
                Divider()
                asThemeInputView
                Divider()
                backgroundColorAndImageView
            }
        case .SheetActivities:
            titleInputAndBackgroundView
        }
    }

}

struct EditThemeOrSheetGeneralViewUI_Previews: PreviewProvider {
    @State static var editViewModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .theme(nil), isUniversal: false)!)
    @State static var isExpanded = true
    static var previews: some View {
        EditThemeOrSheetGeneralViewUI(isSectionGeneralExpanded: $isExpanded, editSheetOrThemeModel: editViewModel)
    }
}
