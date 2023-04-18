//
//  EditThemeOrSheetViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EditThemeOrSheetViewUI: View {
    
    let dismiss: ((_ dismissPresenting: Bool) -> Void)
    let navigationTitle: String
    @State var isSectionGeneralExpanded = true
    @State var isSectionTitleExpanded = false
    @State var isSectionContentExpanded = false
    @State var isSectionImageExpanded = false
    @ObservedObject var editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>
    @State var progress: CGFloat = 0
    @State var submitThemeUseCaseResult: SubmitEntitiesUseCase<ThemeCodable>.ProgressResult = .idle
    @State var submitThemeUseCase: SubmitEntitiesUseCase<ThemeCodable>?
    var body: some View {
        ZStack {
            NavigationStack {
                GeometryReader { proxy in
                    VStack(){
                        HStack {
                            Spacer(minLength: 0)
                            switch editSheetOrThemeModel.item.sheetType {
                            case .SheetTitleImage:
                                sheetTitleImage(viewSize: proxy.size)
                            case .SheetEmpty:
                                sheetEmpty(viewSize: proxy.size)
                            case .SheetPastors:
                                sheetPastors(viewSize: proxy.size)
                            default:
                                sheetTitleContent(viewSize: proxy.size)
                            }
                            Spacer(minLength: 0)
                        }
                        ScrollViewReader { proxy in
                            ScrollView(.vertical) {
                                EditThemeOrSheetGeneralViewUI(
                                    scrollViewProxy: proxy,
                                    isSectionGeneralExpanded: $isSectionGeneralExpanded,
                                    editSheetOrThemeModel: editSheetOrThemeModel
                                )
                                if !isEmptySheet {
                                    EditThemeOrSheetTitleViewUI(
                                        scrollViewProxy: proxy,
                                        isSectionTitleExpanded: $isSectionTitleExpanded,
                                        editSheetOrThemeModel: editSheetOrThemeModel,
                                        selectedAlignmentValue: getAlignmentValue()
                                    )
                                    EditThemeOrSheetContentViewUI(
                                        scrollViewProxy: proxy,
                                        isSectionContentExpanded: $isSectionContentExpanded,
                                        editSheetOrThemeModel: editSheetOrThemeModel,
                                        contentColor: editSheetOrThemeModel.item.contentTextColorHex?.color ?? .black,
                                        selectedAlignmentValue: EditThemeOrSheetContentViewUI.fontAlignmentPickerValues.first(where: { ($0.value as? (Int, String))?.0 ?? -1 == editSheetOrThemeModel.item.contentAlignmentNumber }) ?? EditThemeOrSheetContentViewUI.fontAlignmentPickerValues.first!)
                                }
                                if hasSheetImage() {
                                    EditThemeOrSheetSheetImageViewUI(
                                        scrollViewProxy: proxy,
                                        isSectionSheetImageExpanded: $isSectionImageExpanded,
                                        editSheetOrThemeModel: editSheetOrThemeModel
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
                .edgesIgnoringSafeArea([.bottom])
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle(AppText.NewTheme.title)
                .navigationBarItems(leading:
                                        Button(action: {
                    dismiss(false)
                }) {
                    Text(AppText.Actions.cancel)
                }
                                    , trailing:
                                        Button(action: {
                    do {
                        if let theme = try editSheetOrThemeModel.item.createThemeCodable() {
                            self.submitThemeUseCase = SubmitEntitiesUseCase(
                                endpoint: .themes,
                                requestMethod: editSheetOrThemeModel.item.requestMethod,
                                uploadObjects: [theme],
                                result: $submitThemeUseCaseResult
                            )
                            self.submitThemeUseCase?.submit()
                        }
                    } catch {
                        submitThemeUseCaseResult = .finished(.failure(error))
                    }
                }) {
                    Text(AppText.Actions.save)
                }
                )
            }
            .ignoresSafeArea()
            .blur(radius: submitThemeUseCaseResult.progress != 0 ? 8 : 0)
            if submitThemeUseCaseResult.progress != 0 {
                ProgressControllerUI(circleProgress: $progress, action: .uploading)
            }
        }
        .ignoresSafeArea()
        .onChange(of: submitThemeUseCaseResult) { newValue in
            progress = newValue.progress
            if progress == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
                    self.submitThemeUseCaseResult = .idle
                    self.progress = 0
                    self.dismiss(true)
                })
            }
        }
    }
    
    @ViewBuilder func sheetTitleContent(viewSize: CGSize) -> some View {
        TitleContentViewUI(editViewModel: editSheetOrThemeModel, scaleFactor: getScaleFactor(width: getSheetSizeFor(viewSize).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize).height).width : getSheetSizeFor(viewSize).width!), isForExternalDisplay: false)
            .frame(
                width: getSheetSizeFor(viewSize).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize).height).width  : getSheetSizeFor(viewSize).width!,
                height: getSheetSizeFor(viewSize).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder func sheetTitleImage(viewSize: CGSize) -> some View {
        TitleImageViewUI(editViewModel: editSheetOrThemeModel, scaleFactor: getScaleFactor(width: getSheetSizeFor(viewSize).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize).height).width : getSheetSizeFor(viewSize).width!), isForExternalDisplay: false)
            .frame(
                width: getSheetSizeFor(viewSize).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize).height).width  : getSheetSizeFor(viewSize).width!,
                height: getSheetSizeFor(viewSize).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder func sheetEmpty(viewSize: CGSize) -> some View {
        EmptyViewUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: false)
            .frame(
                width: getSheetSizeFor(viewSize).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize).height).width  : getSheetSizeFor(viewSize).width!,
                height: getSheetSizeFor(viewSize).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder func sheetPastors(viewSize: CGSize) -> some View {
        PastorsViewUI(editViewModel: editSheetOrThemeModel, scaleFactor: getScaleFactor(width: getSheetSizeFor(viewSize).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize).height).width : getSheetSizeFor(viewSize).width!), isForExternalDisplay: false)
            .frame(
                width: getSheetSizeFor(viewSize).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize).height).width  : getSheetSizeFor(viewSize).width!,
                height: getSheetSizeFor(viewSize).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder func sectionHeaderWith(title: String) -> some View {
        Text(title)
            .padding(EdgeInsets(5))
            .font(.title3)
            .foregroundColor(.black.opacity(0.8))
    }
    
    @ViewBuilder func viewsForSheet(_ type: SheetMetaType) -> some View {
        TextFieldViewUI(
            textFieldViewModel: TextFieldViewModel(
                label: AppText.NewTheme.descriptionTitle,
                placeholder: AppText.NewTheme.descriptionTitlePlaceholder,
                characterLimit: 80,
                text: $editSheetOrThemeModel.item.title
            )
        )
    }
    
    @ViewBuilder var sectionTitle: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionTitleExpanded) {
                Divider()
                Text("Title")
                    .padding(EdgeInsets(5))
            } label: {
                sectionHeaderWith(title: AppText.NewTheme.sectionTitle)
            }
            .accentColor(.black.opacity(0.8))
        }
    }
    
    @ViewBuilder var sectionContent: some View {
        GroupBox() {
            DisclosureGroup(isExpanded: $isSectionContentExpanded) {
                Divider()
                Text("Content")
                    .padding(EdgeInsets(5))
            } label: {
                sectionHeaderWith(title: AppText.NewTheme.sectionLyrics)
            }
            .accentColor(.black.opacity(0.8))
        }
    }
    
    private func getAlignmentValue() -> PickerRepresentable {
        let titleAlignmentValue = EditThemeOrSheetTitleViewUI.fontAlignmentPickerValues.first { value in
            if let value = value.value as? (Int, String) {
                if value.0 == editSheetOrThemeModel.item.titleAlignmentNumber {
                    return true
                }
                return false
            }
            return false
        }
        return titleAlignmentValue ?? EditThemeOrSheetTitleViewUI.fontAlignmentPickerValues.first!
    }
    
    private func getSheetSizeFor(_ containerSize: CGSize) -> (width: CGFloat?, height: CGFloat) {
        (width: containerSize.width > containerSize.height ? min(containerSize.width, 500) : nil,
            height: getSizeWith(width: containerSize.width > containerSize.height ? min(containerSize.width, 500) : containerSize.width).height
        )
    }
    
    private func hasSheetImage() -> Bool {
        [SheetType.SheetTitleImage, SheetType.SheetPastors].contains(where: { $0.rawValue == editSheetOrThemeModel.item.sheetType.rawValue })
    }
    
    private var isEmptySheet: Bool {
        func isEmptySheetType(type: SheetType) -> Bool {
            switch type {
            case .SheetEmpty: return true
            case .SheetTitleContent, .SheetTitleImage, .SheetPastors, .SheetSplit, .SheetActivities: return false
            }
        }
        switch editSheetOrThemeModel.item.editMode {
        case .newSheet(_, sheetType: let type):
            return isEmptySheetType(type: type)
        case .persistedSheet(_, sheetType: let type):
            return isEmptySheetType(type: type)
        case .newTheme, .persistedTheme: return false
        }
    }

}

struct EditThemeOrSheetViewUI_Previews: PreviewProvider {
    @State static var sheetPastors = SheetPastorsCodable.makeDefault()
    @State static var model = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .persistedSheet(sheetPastors, sheetType: .SheetPastors), isUniversal: false, image: UIImage(named: "Pio-Sebastiaan-en-Marilou.jpg"))!)
    static var previews: some View {
        EditThemeOrSheetViewUI(dismiss: { _ in }, navigationTitle: "", editSheetOrThemeModel: model, submitThemeUseCaseResult: .idle)
    }
}
