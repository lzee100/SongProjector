//
//  EditThemeOrSheetGeneralViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EditThemeOrSheetGeneralViewUI: View {
    
    private let scrollViewProxy: ScrollViewProxy?
    @Binding private var isSectionGeneralExpanded: Bool
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(scrollViewProxy: ScrollViewProxy? = nil, isSectionGeneralExpanded: Binding<Bool>, sheetViewModel: SheetViewModel) {
        self.scrollViewProxy = scrollViewProxy
        self._isSectionGeneralExpanded = isSectionGeneralExpanded
        self.sheetViewModel = sheetViewModel
    }

    var body: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionGeneralExpanded) {
                Divider()
                switch sheetViewModel.sheetEditType {
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
                case .custom, .bibleStudy, .lyrics:
                    viewForSheet(sheetViewModel.sheetModel.sheetType)
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
            LabelColorPickerViewUI(label: AppText.NewTheme.descriptionBackgroundColor, defaultColor: .white, selectedColor: sheetViewModel.themeModel.theme.backgroundColor?.color ?? .white) { color in
                sheetViewModel.themeModel.theme.backgroundColor = color
            }
            
            Divider()
            
            LabelPhotoPickerViewUI(label: AppText.NewTheme.backgroundImage, selectedImage: sheetViewModel.themeModel.getImage(thumb: true)) { image in
                if let image {
                    sheetViewModel.themeModel.newSelectedImage = image
                } else {
                    sheetViewModel.themeModel.deleteThemeImage()
                }
            }
            
            if sheetViewModel.themeModel.getImage(thumb: true) != nil {
                Slider(value: $sheetViewModel.themeModel.theme.backgroundTransparancyNumber, in: 0.0...1.0) {
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
                label: AppText.NewTheme.sectionTitle,
                placeholder: AppText.NewTheme.descriptionTitlePlaceholder,
                characterLimit: 80,
                text: $sheetViewModel.title
            )
        )
    }
    
    @ViewBuilder var ContentInputView: some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: AppText.NewSheetTitleImage.descriptionContent,
                placeholder: AppText.NewTheme.sampleLyrics,
                characterLimit: 400,
                text: $sheetViewModel.sheetModel.content
            )
        )
    }
    
    @ViewBuilder var ContentInputLeftView: some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: AppText.NewSheetTitleImage.descriptionTextLeft,
                placeholder: AppText.NewTheme.sampleLyrics,
                characterLimit: 400,
                text: $sheetViewModel.sheetModel.content
            )
        )
    }
    
    @ViewBuilder var ContentInputRightView: some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: AppText.NewSheetTitleImage.descriptionTextRight,
                placeholder: AppText.NewTheme.sampleLyrics,
                characterLimit: 400,
                text: $sheetViewModel.sheetModel.contentRight
            )
        )
    }
    
    @ViewBuilder var asThemeInputView: some View {
        PickerViewUI(
            label: AppText.NewTheme.descriptionAsTheme,
            getPickerValues: {
                await GetThemesUseCase().fetch().map { $0.pickerRepresentable }
            },
            pickerValues: [],
            selectedItem: nil) { value in
                if let theme = value.value as? ThemeCodable {
                    sheetViewModel.themeModel.styleAs(theme)
                }
            }
    }
    
    @ViewBuilder var displayEmptySheetAndAsFirst: some View {
        ToggleViewUI(label: AppText.NewTheme.descriptionHasEmptySheet, isOn: $sheetViewModel.themeModel.theme.hasEmptySheet)
        
                if sheetViewModel.themeModel.theme.hasEmptySheet {
                    Divider()
                    ToggleViewUI(label: AppText.NewTheme.descriptionPositionEmptySheet, isOn: $sheetViewModel.themeModel.theme.isEmptySheetFirst)
                }
    }
    
    @ViewBuilder var allSheetsHaveTitle: some View {
        ToggleViewUI(label: AppText.NewTheme.descriptionAllTitle, isOn: $sheetViewModel.themeModel.theme.allHaveTitle)
    }
    
    @ViewBuilder var dividerAndDisplayTime: some View {
        VStack {
            Divider()
            ToggleViewUI(label: AppText.NewTheme.descriptionDisplayTime, isOn: $sheetViewModel.themeModel.theme.displayTime)
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
