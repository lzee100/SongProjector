//
//  EditThemeOrSheetContentViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EditThemeOrSheetContentViewUI: View {
    
    var scrollViewProxy: ScrollViewProxy? = nil
    @Binding var isSectionContentExpanded: Bool
    @ObservedObject var editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>
    @State var contentColor: Color = .black
//    @State var contentBorderColor: Color = .black
    @State var selectedAlignmentValue: PickerRepresentable
    
    var body: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionContentExpanded) {
                Divider()
                switch editSheetOrThemeModel.item.editMode {
                case .theme:
                    viewsPartOne(hasBackgroundColorAndAlignment: true)
                    viewsPartTwo
                case .sheet(_, let type):
                    viewFor(type)
                }
            } label: {
                Text(editSheetOrThemeModel.item.editMode.isSheet ? AppText.NewSheetTitleImage.sectionContentTitle : AppText.NewTheme.sectionLyrics)
                    .styleAsSection
            }
            .accentColor(.black.opacity(0.8))
        }
        .onChange(of: isSectionContentExpanded) { newValue in
            withAnimation(.linear.delay(0.3)) {
                scrollViewProxy?.scrollTo(3, anchor: .bottom)
            }
        }
    }
    
    @ViewBuilder func viewFor(_ sheetType: SheetType) -> some View {
        switch sheetType {
        case .SheetEmpty: EmptyView()
        case .SheetTitleContent, .SheetTitleImage:
            VStack {
                viewsPartOne(hasBackgroundColorAndAlignment: true)
                viewsPartTwo
            }
        case .SheetPastors, .SheetActivities, .SheetSplit:
            VStack {
                viewsPartOne(hasBackgroundColorAndAlignment: false)
                viewsPartTwo
            }
        }
    }
    
    @ViewBuilder func viewsPartOne(hasBackgroundColorAndAlignment: Bool) -> some View {
        VStack {
            contentFontPickerView
            Divider()
            contentFontSizeModifierView
            if hasBackgroundColorAndAlignment {
                Divider()
                contentAlignmentView
            }
            Divider()
            contentForegroundColorView
        }
    }
    
    @ViewBuilder var viewsPartTwo: some View {
        VStack {
//            Divider()
//            contentBorderSizeModifierView
//            Divider()
//            contentBorderColorView
            Divider()
            contentBoldToggleView.id(3)
            Divider()
            contentItalicToggleView
            Divider()
            contentUnderlinedToggleView
        }
    }
        
    @ViewBuilder private var contentFontPickerView: some View {
        PickerViewUI(label: AppText.NewTheme.fontFamilyDescription, pickerValues: fontNamePickerValues) { container in
            if let fontName = container.value as? String {
                editSheetOrThemeModel.item.contentFontName = fontName
            }
        }
    }
    
    @ViewBuilder private var contentAlignmentView: some View {
        PickerViewUI(label: AppText.NewTheme.descriptionAlignment, pickerValues: Self.fontAlignmentPickerValues, selectedItem: $selectedAlignmentValue) { container in
            if let alignmentTuple = container.value as? (Int, String) {
                editSheetOrThemeModel.item.contentAlignmentNumber = Int16(alignmentTuple.0)
            }
        }
    }
    
    @ViewBuilder private var contentFontSizeModifierView: some View {
        NumberModifierViewUI(viewModel: NumberModifierViewModel(label: AppText.NewTheme.fontSizeDescription, allowSubstraction: { value in
            return value > 4
        }, allowIncrement: { value in
            return value < 30
        }, numberValue: $editSheetOrThemeModel.item.contentTextSize))
    }
    
//    @ViewBuilder private var contentBorderSizeModifierView: some View {
//        NumberModifierViewUI(viewModel: NumberModifierViewModel(label: AppText.NewTheme.borderSizeDescription, allowSubstraction: { value in
//            return true
//        }, allowIncrement: { value in
//            return value <= 10
//        }, numberValue: $editSheetOrThemeModel.item.contentBorderSize))
//    }

    @ViewBuilder private var contentForegroundColorView: some View {
        LabelColorPickerViewUI(label: AppText.NewTheme.textColor, defaultColor: .black, colorDidChange: { newColor in
            editSheetOrThemeModel.item.contentTextColorHex = newColor
        }, selectedColor: $contentColor)
    }
    
//    @ViewBuilder private var contentBorderColorView: some View {
//        LabelColorPickerViewUI(label: AppText.NewTheme.borderColor, defaultColor: .black, colorDidChange: { newColor in
//            editSheetOrThemeModel.item.contentBorderColorHex = newColor
//        }, selectedColor: $contentBorderColor)
//    }
    
    @ViewBuilder private var contentBoldToggleView: some View {
        ToggleViewUI(label: AppText.NewTheme.bold, isOn: $editSheetOrThemeModel.item.isContentBold)
    }

    @ViewBuilder private var contentItalicToggleView: some View {
        ToggleViewUI(label: AppText.NewTheme.italic, isOn: $editSheetOrThemeModel.item.isContentItalic)
    }

    @ViewBuilder private var contentUnderlinedToggleView: some View {
        ToggleViewUI(label: AppText.NewTheme.underlined, isOn: $editSheetOrThemeModel.item.isContentUnderlined)
    }
    
    private var fontNamePickerValues: [PickerRepresentable] {
        UIFont.familyNames
            .flatMap { UIFont.fontNames(forFamilyName: $0) }.map { PickerRepresentable(value: $0, label: $0) }
    }
    
    static let fontAlignmentPickerValues: [PickerRepresentable] =
    [(0, AppText.NewTheme.alignLeft), (1, AppText.NewTheme.alignCenter), (2, AppText.NewTheme.alignRight)].map { PickerRepresentable(value: $0, label: $0.1) }
}

struct EditThemeOrSheetContentViewUI_Previews: PreviewProvider {
    @State static var editViewModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .theme(nil), isUniversal: false)!)
    @State static var selectedcontentAlignment = EditThemeOrSheetContentViewUI.fontAlignmentPickerValues.first!
    @State static var isSectionExpanded = true
    static var previews: some View {
        EditThemeOrSheetContentViewUI(isSectionContentExpanded: $isSectionExpanded, editSheetOrThemeModel: editViewModel, selectedAlignmentValue: selectedcontentAlignment)
    }
}
