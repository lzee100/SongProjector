//
//  EditThemeOrSheetViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

protocol EditThemeOrSheetViewUIDelegate {
    func dismiss()
}

@MainActor class ThemeEditorViewModel: ObservableObject {
    
    @Published var error: LocalizedError?
    @Published private(set) var showingLoader = false
    private(set) var editModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    init(error: LocalizedError? = nil, showingLoader: Bool = false, editModel: WrappedStruct<EditSheetOrThemeViewModel>) {
        self.error = error
        self.showingLoader = showingLoader
        self.editModel = editModel
    }
    
    func submitTheme() async {
        setIsLoading(true)
        do {
            if let theme = try editModel.item.createThemeCodable() {
                let result = try await SubmitUseCase(endpoint: .themes, requestMethod: .put, uploadObjects: [theme]).submit()
                setIsLoading(false)
            }
        } catch {
            setIsLoading(false)
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    private func setIsLoading(_ showingLoader: Bool) {
        withAnimation(.linear) {
            self.showingLoader = showingLoader
        }
    }

}


struct EditThemeOrSheetViewUI: View {
    
    let navigationTitle: String
    
    let delegate: EditThemeOrSheetViewUIDelegate?
    @State var editingCollectionModel: CollectionEditorViewModel? // TODO: remove, do in didDismiss
    @State var isSectionGeneralExpanded = true
    @State var isSectionTitleExpanded = false
    @State var isSectionContentExpanded = false
    @State var isSectionImageExpanded = false
    @ObservedObject var editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>
    @StateObject var viewModel: ThemeEditorViewModel
    
    init(navigationTitle: String, delegate: EditThemeOrSheetViewUIDelegate?, editingCollectionModel: CollectionEditorViewModel? = nil, isSectionGeneralExpanded: Bool = true, isSectionTitleExpanded: Bool = false, isSectionContentExpanded: Bool = false, isSectionImageExpanded: Bool = false, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>) {
        self.navigationTitle = navigationTitle
        self.delegate = delegate
        self._editingCollectionModel = State(initialValue: editingCollectionModel)
        self._isSectionGeneralExpanded = State(initialValue: isSectionGeneralExpanded)
        self._isSectionTitleExpanded = State(initialValue: isSectionTitleExpanded)
        self._isSectionContentExpanded = State(initialValue: isSectionContentExpanded)
        self._isSectionImageExpanded = State(initialValue: isSectionImageExpanded)
        self.editSheetOrThemeModel = editSheetOrThemeModel
        self._viewModel = StateObject(wrappedValue: ThemeEditorViewModel(editModel: editSheetOrThemeModel))
    }

    var body: some View {
        NavigationStack {
                GeometryReader { proxy in
                    VStack(){
                        HStack {
                            Spacer(minLength: 0)
                            SheetUIHelper.sheet(ratioOnHeight: false, maxWidth: 500, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: false)
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
                    .blur(radius: viewModel.showingLoader ? 5 : 0)
                    .disabled(viewModel.showingLoader)
                }
                .errorAlert(error: $viewModel.error)
                .padding()
                .edgesIgnoringSafeArea([.bottom])
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle(editSheetOrThemeModel.item.editMode.isSheet ? AppText.NewSheetTitleImage.title : AppText.NewTheme.title)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            delegate?.dismiss()
                        } label: {
                            Text(AppText.Actions.cancel)
                        }
                        .tint(Color(uiColor: themeHighlighted))
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if let editingCollectionModel {
                            Button {
                                if let index = editingCollectionModel.getIndexOf(editSheetOrThemeModel.item) {
                                    editingCollectionModel.sheets.remove(at: index)
                                    editingCollectionModel.sheets.insert(editSheetOrThemeModel.item, at: index)
                                } else {
                                    editingCollectionModel.sheets.append(editSheetOrThemeModel.item)
                                }
                                delegate?.dismiss()
                            } label: {
                                if editingCollectionModel.getIndexOf(editSheetOrThemeModel.item) == nil {
                                    Text(AppText.Actions.add)
                                } else {
                                    Text(AppText.Actions.change)
                                }
                            }
                            .tint(Color(uiColor: themeHighlighted))
                        } else {
                            Button {
                                Task {
                                   await viewModel.submitTheme()
                                }
                            } label: {
                                Text(AppText.Actions.save)
                            }
                            .tint(Color(uiColor: themeHighlighted))
                        }
                    }
                })
            }
        .ignoresSafeArea()
        .onChange(of: viewModel.showingLoader) { newValue in
            if !newValue {
                delegate?.dismiss()
            }
        }
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
        
    private func hasSheetImage() -> Bool {
        [SheetType.SheetTitleImage, SheetType.SheetPastors].contains(where: { $0.rawValue == editSheetOrThemeModel.item.sheetType.rawValue })
    }
    
    private var isEmptySheet: Bool {
        switch editSheetOrThemeModel.item.editMode {
        case .sheet(_, sheetType: let type):
            switch type {
            case .SheetEmpty: return true
            case .SheetTitleContent, .SheetTitleImage, .SheetPastors, .SheetSplit, .SheetActivities: return false
            }
        case .theme: return false
        }
    }
    
}

struct EditThemeOrSheetViewUI_Previews: PreviewProvider {
    @State static var isShowingEditor = false
    @State static var cluster = ClusterCodable.makeDefault()!
    @State static var activities = SheetActivitiesCodable.makeDefault()
    @State static var model = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .sheet((cluster, activities), sheetType: .SheetActivities), isUniversal: false, image: UIImage(named: "Pio-Sebastiaan-en-Marilou.jpg"))!)
    static var previews: some View {
        EditThemeOrSheetViewUI(navigationTitle: "", delegate: nil, editingCollectionModel: nil, editSheetOrThemeModel: model)
    }
}
