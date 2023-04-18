//
//  EditThemeOrSheetTitleViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EditThemeOrSheetTitleViewUI: View {
    
    var scrollViewProxy: ScrollViewProxy? = nil
    @Binding var isSectionTitleExpanded: Bool
    @ObservedObject var editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>
    @State var titleColor: Color = .black
    @State var titleBorderColor: Color = .black
    @State var selectedAlignmentValue: PickerRepresentable
    
    var body: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionTitleExpanded) {
                Divider()
                switch editSheetOrThemeModel.item.editMode {
                case .newTheme, .persistedTheme:
                    titleViewsPartOne(hasBackgroundColorAndAlignment: true)
                    titleViewsPartTwo
                case .newSheet(_ , let type):
                    viewFor(type)
                case .persistedSheet(_, let type):
                    viewFor(type)
                }
            } label: {
                Text(AppText.NewTheme.sectionTitle)
                    .styleAsSection
            }
            .accentColor(.black.opacity(0.8))
        }
        .onChange(of: isSectionTitleExpanded) { newValue in
            withAnimation(.linear.delay(0.3)) {
                scrollViewProxy?.scrollTo(2, anchor: .bottom)
            }
        }
    }
    
    @ViewBuilder func viewFor(_ sheetType: SheetType) -> some View {
        switch sheetType {
        case .SheetEmpty: EmptyView()
        case .SheetTitleContent, .SheetTitleImage:
            VStack {
                titleViewsPartOne(hasBackgroundColorAndAlignment: true)
                titleViewsPartTwo
            }
        case .SheetPastors, .SheetActivities, .SheetSplit:
            VStack {
                titleViewsPartOne(hasBackgroundColorAndAlignment: false)
                titleViewsPartTwo
            }
        }
    }
    
    @ViewBuilder func titleViewsPartOne(hasBackgroundColorAndAlignment: Bool) -> some View {
        VStack {
            titleFontPickerView
            Divider()
            titleFontSizeModifierView
            if hasBackgroundColorAndAlignment {
                Divider()
                titleAlignmentView
            }
            Divider()
            titleForegroundColorView
        }
    }
    
    @ViewBuilder var titleViewsPartTwo: some View {
        VStack {
//            Divider()
//            titleBorderSizeModifierView
//            Divider()
//            titleBorderColorView
            Divider()
            titleBoldToggleView.id(2)
            Divider()
            titleItalicToggleView
            Divider()
            titleUnderlinedToggleView
        }
    }
        
    @ViewBuilder private var titleFontPickerView: some View {
        PickerViewUI(label: AppText.NewTheme.fontFamilyDescription, pickerValues: fontNamePickerValues) { container in
            if let fontName = container.value as? String {
                editSheetOrThemeModel.item.titleFontName = fontName
            }
        }
    }
    
    @ViewBuilder private var titleAlignmentView: some View {
        PickerViewUI(label: AppText.NewTheme.descriptionAlignment, pickerValues: Self.fontAlignmentPickerValues, selectedItem: $selectedAlignmentValue) { container in
            if let alignmentTuple = container.value as? (Int, String) {
                editSheetOrThemeModel.item.titleAlignmentNumber = Int16(alignmentTuple.0)
            }
        }
    }
    
    @ViewBuilder private var titleFontSizeModifierView: some View {
        NumberModifierViewUI(viewModel: NumberModifierViewModel(label: AppText.NewTheme.fontSizeDescription, allowSubstraction: { value in
            return value > 4
        }, allowIncrement: { value in
            return value < 30
        }, numberValue: $editSheetOrThemeModel.item.titleTextSize))
    }
    
    @ViewBuilder private var titleBorderSizeModifierView: some View {
        NumberModifierViewUI(viewModel: NumberModifierViewModel(label: AppText.NewTheme.borderSizeDescription, allowSubstraction: { value in
            return true
        }, allowIncrement: { value in
            return value <= 10
        }, numberValue: $editSheetOrThemeModel.item.titleBorderSize))
    }

    @ViewBuilder private var titleForegroundColorView: some View {
        LabelColorPickerViewUI(label: AppText.NewTheme.textColor, defaultColor: .black, colorDidChange: { newColor in
            editSheetOrThemeModel.item.titleTextColorHex = newColor
        }, selectedColor: $titleColor)
    }
    
    @ViewBuilder private var titleBorderColorView: some View {
        LabelColorPickerViewUI(label: AppText.NewTheme.borderColor, defaultColor: .black, colorDidChange: { newColor in
            editSheetOrThemeModel.item.titleBorderColorHex = newColor
        }, selectedColor: $titleBorderColor)
    }
    
    @ViewBuilder private var titleBoldToggleView: some View {
        ToggleViewUI(label: AppText.NewTheme.bold, isOn: $editSheetOrThemeModel.item.isTitleBold)
    }

    @ViewBuilder private var titleItalicToggleView: some View {
        ToggleViewUI(label: AppText.NewTheme.italic, isOn: $editSheetOrThemeModel.item.isTitleItalic)
    }

    @ViewBuilder private var titleUnderlinedToggleView: some View {
        ToggleViewUI(label: AppText.NewTheme.underlined, isOn: $editSheetOrThemeModel.item.isTitleUnderlined)
    }
    
    private var fontNamePickerValues: [PickerRepresentable] {
        UIFont.familyNames.map { PickerRepresentable(value: $0, label: $0) }
    }
    
    static let fontAlignmentPickerValues: [PickerRepresentable] =
    [(0, AppText.NewTheme.alignLeft), (1, AppText.NewTheme.alignCenter), (2, AppText.NewTheme.alignRight)].map { PickerRepresentable(value: $0, label: $0.1) }

}

struct EditThemeOrSheetTitleViewUI_Previews: PreviewProvider {
    @State static var editViewModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .newTheme, isUniversal: false)!)
    @State static var selectedTitleAlignment = EditThemeOrSheetTitleViewUI.fontAlignmentPickerValues.first!
    @State static var isSectionExpanded = true
    static var previews: some View {
        EditThemeOrSheetTitleViewUI(isSectionTitleExpanded: $isSectionExpanded, editSheetOrThemeModel: editViewModel, selectedAlignmentValue: selectedTitleAlignment)
    }
}
