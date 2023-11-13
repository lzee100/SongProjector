//
//  EditThemeOrSheetViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

protocol EditThemeOrSheetViewUIDelegate {
    func dismissAndSave(model: SheetViewModel)
    func dismiss()
}

@MainActor class EditThemeOrSheetViewModel: ObservableObject {
    
    enum RightNavigationBarButton {
        case submitTheme
        case addNewSheet
        case changeSheet
    }
    
    @Published var error: LocalizedError?
    @Published var showingSubscriptionsView = false
    @Published var isSavingEnabled = true
    @Published private(set) var showingLoader = false
    @ObservedObject var sheetViewModel: SheetViewModel
    var navigationBarTitle: String {
        switch sheetViewModel.sheetEditType {
        case .theme:
            return sheetViewModel.themeModel.isNew ? AppText.NewTheme.title : AppText.EditTheme.title
        case .lyrics:
            return sheetViewModel.sheetModel.isNew ? AppText.NewSong.newLyrics : AppText.NewSong.changeLyrics
        case .bibleStudy:
            return sheetViewModel.sheetModel.isNew ? AppText.Lyrics.titleBibleText : AppText.Lyrics.titleBibleTextChange
        case .custom:
            return sheetViewModel.sheetModel.isNew ? AppText.CustomSheetsEdit.title : AppText.CustomSheetsEdit.titleChange
        }
    }
    
    var rightNavigationBarButton: RightNavigationBarButton {
        switch sheetViewModel.sheetEditType {
        case .theme:
            return .submitTheme
        default:
            return sheetViewModel.sheetModel.isNew ? .addNewSheet : .changeSheet
        }
    }
    
    init(error: LocalizedError? = nil, showingLoader: Bool = false, sheetViewModel: SheetViewModel) {
        self.error = error
        self.showingLoader = showingLoader
        self._sheetViewModel = ObservedObject(initialValue: sheetViewModel)
    }
    
    func submitTheme() async {
        setIsLoading(true)
        do {
            if let theme = try sheetViewModel.createThemeCodable() {
                _ = try await SubmitUseCase(endpoint: .themes, requestMethod: .put, uploadObjects: [theme]).submit()
                setIsLoading(false)
            }
        } catch {
            setIsLoading(false)
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }

    func checkSubscriptionsStatus() async {
        let status = await GetActiveSubscriptionsUseCase().fetch()
        isSavingEnabled = status != .none
    }

    private func setIsLoading(_ showingLoader: Bool) {
        withAnimation(.linear) {
            self.showingLoader = showingLoader
        }
    }

}


struct EditThemeOrSheetViewUI: View {
    
    let navigationTitle: String
    
    let delegate: EditThemeOrSheetViewUIDelegate
    @State var isSectionGeneralExpanded = true
    @State var isSectionTitleExpanded = false
    @State var isSectionContentExpanded = false
    @State var isSectionImageExpanded = false
    @StateObject var viewModel: EditThemeOrSheetViewModel
    
    init(
        navigationTitle: String,
        delegate: EditThemeOrSheetViewUIDelegate,
        isSectionGeneralExpanded: Bool = true,
        isSectionTitleExpanded: Bool = false,
        isSectionContentExpanded: Bool = false,
        isSectionImageExpanded: Bool = false,
        sheetViewModel: SheetViewModel
    ) {
        self.navigationTitle = navigationTitle
        self.delegate = delegate
        self._isSectionGeneralExpanded = State(initialValue: isSectionGeneralExpanded)
        self._isSectionTitleExpanded = State(initialValue: isSectionTitleExpanded)
        self._isSectionContentExpanded = State(initialValue: isSectionContentExpanded)
        self._isSectionImageExpanded = State(initialValue: isSectionImageExpanded)
        self._viewModel = StateObject(wrappedValue: EditThemeOrSheetViewModel(sheetViewModel: sheetViewModel))
    }

    var body: some View {
        NavigationStack {
                GeometryReader { proxy in
                    VStack(){
                        HStack {
                            Spacer(minLength: 0)
                            SheetUIHelper.sheet(sheetViewModel: viewModel.sheetViewModel, isForExternalDisplay: false)
                            Spacer(minLength: 0)
                        }
                        ScrollViewReader { proxy in
                            ScrollView(.vertical) {
                                EditThemeOrSheetGeneralViewUI(
                                    scrollViewProxy: proxy,
                                    isSectionGeneralExpanded: $isSectionGeneralExpanded,
                                    sheetViewModel: viewModel.sheetViewModel
                                )
                                if !isEmptySheet {
                                    EditThemeOrSheetTitleViewUI(
                                        scrollViewProxy: proxy,
                                        isSectionTitleExpanded: $isSectionTitleExpanded,
                                        sheetViewModel: viewModel.sheetViewModel,
                                        selectedAlignmentValue: getAlignmentValue()
                                    )
                                    EditThemeOrSheetContentViewUI(
                                        scrollViewProxy: proxy,
                                        isSectionContentExpanded: $isSectionContentExpanded,
                                        sheetViewModel: viewModel.sheetViewModel,
                                        contentColor: viewModel.sheetViewModel.themeModel.theme.contentTextColorHex?.color ?? .black,
                                        selectedAlignmentValue: EditThemeOrSheetContentViewUI.fontAlignmentPickerValues.first(where: { ($0.value as? (Int, String))?.0 ?? -1 == viewModel.sheetViewModel.themeModel.theme.contentAlignmentNumber }) ?? EditThemeOrSheetContentViewUI.fontAlignmentPickerValues.first!)
                                }
                                if hasSheetImage() {
                                    EditThemeOrSheetSheetImageViewUI(
                                        scrollViewProxy: proxy,
                                        isSectionSheetImageExpanded: $isSectionImageExpanded,
                                        sheetViewModel: viewModel.sheetViewModel
                                    )
                                }
                            }
                        }
                    }
                    .blur(radius: viewModel.showingLoader ? 5 : 0)
                    .disabled(viewModel.showingLoader)
                    .overlay {
                        if viewModel.showingLoader {
                            ProgressView()
                                .scaleEffect(1.4)
                        }
                    }
                }
                .errorAlert(error: $viewModel.error)
                .padding()
                .edgesIgnoringSafeArea([.bottom])
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle(viewModel.navigationBarTitle)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            delegate.dismiss()
                        } label: {
                            Text(AppText.Actions.cancel)
                        }
                        .tint(Color(uiColor: themeHighlighted))
                        .disabled(viewModel.showingLoader)
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        navigationBarButtonRight
                            .disabled(viewModel.showingLoader)
                    }
                })
            }
        .ignoresSafeArea()
        .task(priority: .userInitiated, {
            await viewModel.checkSubscriptionsStatus()
        })
        .sheet(isPresented: $viewModel.showingSubscriptionsView, content: {
            SubscriptionsViewUI(subscriptionsStore: SubscriptionsStore())
        })
        .onChange(of: viewModel.showingLoader, { _, newValue in
            if !newValue {
                delegate.dismiss()
            }
        })
    }
    
    @ViewBuilder var navigationBarButtonRight: some View {
        HStack {
            switch viewModel.rightNavigationBarButton {
            case .addNewSheet, .changeSheet:
                Button {
                    if viewModel.isSavingEnabled {
                        delegate.dismissAndSave(model: viewModel.sheetViewModel)
                    } else {
                        viewModel.showingSubscriptionsView.toggle()
                    }
                } label: {
                    if case .addNewSheet = viewModel.rightNavigationBarButton {
                        Text(AppText.Actions.add)
                    } else {
                        Text(AppText.Actions.change)
                    }
                }
                .tint(Color(uiColor: themeHighlighted))
            case .submitTheme:
                Button {
                    if viewModel.isSavingEnabled {
                        Task {
                            await viewModel.submitTheme()
                        }
                    } else {
                        viewModel.showingSubscriptionsView.toggle()
                    }
                } label: {
                    Text(AppText.Actions.save)
                }
                .tint(Color(uiColor: themeHighlighted))
            }
        }
    }
    
    @ViewBuilder func sectionHeaderWith(title: String) -> some View {
        Text(title)
            .padding(EdgeInsets(5))
            .font(.title3)
            .foregroundColor(.black.opacity(0.8))
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
                if value.0 == viewModel.sheetViewModel.themeModel.theme.titleAlignmentNumber {
                    return true
                }
                return false
            }
            return false
        }
        return titleAlignmentValue ?? EditThemeOrSheetTitleViewUI.fontAlignmentPickerValues.first!
    }
        
    private func hasSheetImage() -> Bool {
        [.SheetTitleImage, .SheetPastors].contains(viewModel.sheetViewModel.sheetModel.sheetType)
    }
    
    private var isEmptySheet: Bool {
        switch viewModel.sheetViewModel.sheetModel.sheetType {
        case .SheetEmpty:
            return true
        default: return false
        }
    }
}

private struct EditThemeOrSheetViewUIDelegateObject: EditThemeOrSheetViewUIDelegate {
    func dismissAndSave(model: SheetViewModel) {
    }
    
    func dismiss() {
    }
}
