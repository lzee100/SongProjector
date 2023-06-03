//
//  CollectionEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct CollectionEditorViewUI: View {
    
    enum SheetPresentMode: Identifiable {
        var id: String {
            switch self {
            case .bibleStudySheets: return "0"
            }
        }
        
        case bibleStudySheets(content: String)
    }
    
    @StateObject private var viewModel: CollectionEditorViewModel
    @StateObject private var themeSelectionModel: ThemesSelectionModel
    @StateObject private var tagsSelectionModel: TagSelectionModel
    
    @Binding var showingCollectionEditor: CollectionsViewUI.CollectionEditor?
    @State private var sheetSize: CGSize = .zero
    @State private var sheetPresentMode: SheetPresentMode? = nil
    @State private var selectedSheetModel: SheetViewModel?
    @State private var isShowingNoThemeSelectedAlert = false
    @State private var isShowingChangeEditControllerTypeAlert = false
    @State private var isShowingLosingOtherSheetsAlert = false
    @State private var showingTagsExplainedPopOver = false
    @State private var showingTimeExplainedPopOver = false

    init?(cluster: ClusterCodable?, showingCollectionEditor: Binding<CollectionsViewUI.CollectionEditor?>) {
        let themesSelectionModel = ThemesSelectionModel(selectedTheme: cluster?.theme)
        let tagsSelectionModel = TagSelectionModel(mandatoryTags: [], selectedTags: cluster?.hasTags ?? [])
        guard let viewModel = CollectionEditorViewModel(cluster: cluster, themeSelectionModel: themesSelectionModel, tagsSelectionModel: tagsSelectionModel) else {
            return nil
        }
        _themeSelectionModel = StateObject(wrappedValue: themesSelectionModel)
        _tagsSelectionModel = StateObject(wrappedValue: tagsSelectionModel)
        _viewModel = StateObject(wrappedValue: viewModel)
        _showingCollectionEditor = showingCollectionEditor
    }
    
    var body: some View {
        
        NavigationStack {
            List {
                Section {
                    let boundTitle = Binding(
                        get: { self.viewModel.title },
                        set: { self.viewModel.title = $0 }
                    )
                    
                    TextFieldViewUI(textFieldViewModel: TextFieldViewModel(
                        label: nil,
                        placeholder: AppText.NewSong.titlePlaceholder,
                        characterLimit: TextFieldViewModel.CharacterLimit.standaard.rawValue,
                        text: boundTitle
                    ))
                    tagSelectionRowView
                        .observeViewSize()
                        .onPreferenceChange(SizePreferenceKey.self) { size in
                            self.sheetSize = size
                            if viewModel.collectionType.isBibleStudy {
                                Task {
                                    await viewModel.bibleStudyTextDidChange(
                                        updateExistingSheets: true,
                                        parentViewSize: sheetSize
                                    )
                                }
                            }
                        }

                    if viewModel.showTimePickerScrollView {
                        clusterSheettimeRowView
                    }
                }
                
                Section {
                    ThemesScrollViewUI(model: viewModel.themeSelectionModel)
                    sheets
                }

            }
            .blur(radius: viewModel.showingLoader ? 5 : 0)
            .errorAlert(error: $viewModel.error)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(AppText.NewSong.title)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(AppText.Actions.close) {
                        showingCollectionEditor = nil
                    }
                    .tint(Color(uiColor: themeHighlighted))
                    .disabled(viewModel.showingLoader)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    editButtonsFor(viewModel.editActions)
                }
            })
        }
        .interactiveDismissDisabled()
        .sheet(item: $sheetPresentMode, onDismiss: {
            viewModel.updateSheets(sheetSize: sheetSize)
        }, content: { sheetPresenter in
            switch sheetPresenter {
            case .bibleStudySheets(let content):
                LyricsOrBibleStudyInputViewUI(viewModel: LyricsOrBibleStudyInputViewModel(
                    originalContent: content,
                    content: $viewModel.lyricsOrBibleStudyText,
                    cluster: viewModel.cluster,
                    font: .body,
                    collectionType: viewModel.collectionType,
                    sheetPresentMode: $sheetPresentMode
                ))
            }
        })
        .sheet(item: $selectedSheetModel, content: { model in
            EditThemeOrSheetViewUI(
                navigationTitle: AppText.SheetPickerMenu.pickCustom,
                delegate: self,
                sheetViewModel: model
            )
        })
        .alert(AppText.CustomSheets.errorSelectTheme, isPresented: $isShowingNoThemeSelectedAlert, actions: {
            Button("OK", role: .cancel) { }
        })
        .alert(AppText.CustomSheets.errorChangeSheetGenerator, isPresented: $isShowingChangeEditControllerTypeAlert, actions: {
            Button(AppText.Actions.continue, role: .destructive) {
                viewModel.lyricsOrBibleStudyText = ""
                viewModel.deleteAllSheets()
                if viewModel.collectionType.isBibleStudy {
                    viewModel.update(collectionType: .lyrics)
                } else {
                    viewModel.update(collectionType: .bibleStudy)
                }
            }
            Button(AppText.Actions.cancel, role: .cancel) { }
        })
        .alert(AppText.CustomSheets.errorLoseOtherSheets, isPresented: $isShowingLosingOtherSheetsAlert, actions: {
            Button(AppText.Actions.continue, role: .destructive) {
                Task {
                    viewModel.deleteOtherSheetsThanBibleStudy()
                    let text = await viewModel.getBibleStudyString()
                    await MainActor.run(body: {
                        sheetPresentMode = .bibleStudySheets(content: text)
                    })
                }
            }
            Button(AppText.Actions.cancel, role: .cancel) { }
        })
        .onChange(of: viewModel.themeSelectionModel.selectedTheme, perform: { _ in
            viewModel.updateSheets(sheetSize: sheetSize)
        })
    }
    
    @ViewBuilder var sheets: some View {
        switch viewModel.collectionType {
        case .bibleStudy:
            bibleStudySheets()
        case .lyrics, .customSheet, .none:
            ForEach(viewModel.sheets) { sheetModel in
                Button {
                    if viewModel.collectionType == .lyrics {
                        let text = viewModel.getLyricsString()
                        sheetPresentMode = .bibleStudySheets(content: text)
                    } else {
                        selectedSheetModel = sheetModel
                    }
                } label: {
                    SheetUIHelper.sheet(sheetViewModel: sheetModel, isForExternalDisplay: false)
                }
                .buttonStyle(.borderless)
                .overlay {
                    if viewModel.canDeleteSheets {
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    viewModel.delete(model: sheetModel)
                                } label: {
                                    Image(systemName: "trash")
                                        .tint(Color(uiColor: themeHighlighted))
                                        .padding(20)
                                        .background {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(.black.opacity(0.3))
                                        }
                                        .padding()
                                }
                                .buttonStyle(.borderless)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .onMove { source, destination in
                viewModel.sheets.move(fromOffsets: source, toOffset: destination)
            }
        }
    }
    
    @ViewBuilder func bibleStudySheets() -> some View {
            ForEach(viewModel.sheets) { sheetModel in
                SheetUIHelper.sheet(sheetViewModel: sheetModel, isForExternalDisplay: false)
                    .onTapGesture {
                        if viewModel.hasOtherSheetTypes {
                            isShowingLosingOtherSheetsAlert.toggle()
                        } else {
                            Task {
                                let text = await viewModel.getBibleStudyString()
                                await MainActor.run(body: {
                                    sheetPresentMode = .bibleStudySheets(content: text)
                                })
                            }
                        }
                    }
            }
            .onMove { source, destination in
                viewModel.sheets.move(fromOffsets: source, toOffset: destination)
            }
    }
    
    @ViewBuilder var tagSelectionRowView: some View {
        HStack(spacing: 10) {
            ZStack {
                Image(systemName: "tag")
                    .frame(width: 30, height: 30)
                    .tint(Color(uiColor: themeHighlighted))
                    .padding([.trailing], 15)
                Button {
                    showingTagsExplainedPopOver = true
                } label: {
                    Image(systemName: "questionmark")
                        .tint(Color(uiColor: themeHighlighted))
                        .frame(width: 15, height: 15)
                }
                .offset(x: 17, y: -10)
                .buttonStyle(.borderless)
                .popover(isPresented: $showingTagsExplainedPopOver) {
                    Text(AppText.NewSong.tagsExplained)
                        .styleAs(font: .xNormal)
                        .lineLimit(nil)
                        .padding()
                }
            }
            TagSelectionScrollViewUI(viewModel: viewModel.tagsSelectionModel)
        }
    }
    
    @ViewBuilder var clusterSheettimeRowView: some View {
        HStack(spacing: 10) {
            ZStack {
                Image(systemName: "clock")
                    .frame(width: 30, height: 30)
                    .tint(Color(uiColor: themeHighlighted))
                    .padding([.trailing], 15)
                Button {
                    showingTimeExplainedPopOver = true
                } label: {
                    Image(systemName: "questionmark")
                        .tint(Color(uiColor: themeHighlighted))
                        .frame(width: 15, height: 15)
                }
                .offset(x: 17, y: -10)
                .buttonStyle(.borderless)
                .popover(isPresented: $showingTimeExplainedPopOver) {
                    Text(AppText.NewSong.timeExplained)
                        .styleAs(font: .xNormal)
                        .lineLimit(nil)
                        .padding()
                }
            }
            NumberScrollViewUI(min: 1, max: 30, selectedNumber: $viewModel.clusterTime)
                .frame(height: 40)
        }
    }
    
    @ViewBuilder func editButtonsFor(_ editActions: [CollectionEditorViewModel.EditAction]) -> some View {
        HStack {
            ForEach(editActions) { editAction in
                switch editAction {
                case .save:
                    Button {
                        Task {
                            if await viewModel.saveCluster() {
                                await MainActor.run(body: {
                                    showingCollectionEditor = nil
                                })
                            }
                        }
                    } label: {
                        Text(AppText.Actions.save)
                    }
                    .tint(Color(uiColor: themeHighlighted))
                    .disabled(viewModel.showingLoader)
                case .add:
                    menu
                        .disabled(viewModel.showingLoader)
                case .change:
                    Button {
                        Task {
                            let text = viewModel.getLyricsString()
                            sheetPresentMode = .bibleStudySheets(content: text)
                        }
                    } label: {
                        Text(AppText.Actions.change)
                    }
                    .tint(Color(uiColor: themeHighlighted))
                }
            }
        }
    }
    
    private var menu: some View {
        Menu {
            Section {
                Button(AppText.SheetsMenu.lyrics) {
                    if viewModel.themeSelectionModel.selectedTheme == nil {
                        isShowingNoThemeSelectedAlert = true
                    } else if ![.none, .lyrics].contains(viewModel.collectionType) && viewModel.lyricsOrBibleStudyText.count > 0 {
                        isShowingChangeEditControllerTypeAlert.toggle()
                    } else {
                        viewModel.update(collectionType: .lyrics)
                        sheetPresentMode = .bibleStudySheets(content: "")
                    }
                }
            }
            Section {
                ForEach(SheetType.all, id: \.rawValue) { type in
                    Button(type.name) {
                        viewModel.update(collectionType: .customSheet(type: type))
                        Task {
                            let selectedSheetModel = await viewModel.customSheetsEditModel(collectionType: .customSheet(type: type))
                            await MainActor.run {
                                self.selectedSheetModel = selectedSheetModel
                            }
                        }
                    }
                }
            }
            Section {
                Button(AppText.Lyrics.titleBibleText) {
                    if viewModel.themeSelectionModel.selectedTheme == nil {
                        isShowingNoThemeSelectedAlert = true
                    } else if ![.none, .bibleStudy].contains(viewModel.collectionType) && viewModel.lyricsOrBibleStudyText.count > 0 {
                        isShowingChangeEditControllerTypeAlert.toggle()
                    } else if ![.none, .bibleStudy].contains(viewModel.collectionType) && viewModel.hasOtherSheetTypes {
                        isShowingLosingOtherSheetsAlert.toggle()
                    } else {
                        viewModel.update(collectionType: .bibleStudy)
                        sheetPresentMode = .bibleStudySheets(content: "")
                    }
                }
            }
        } label: {
            Label(AppText.Actions.add, systemImage: "plus")
        }
        .tint(Color(uiColor: themeHighlighted))
    }
}

extension CollectionEditorViewUI: EditThemeOrSheetViewUIDelegate {
    
    func dismissAndSave(model: SheetViewModel) {
        viewModel.add(model)
        selectedSheetModel = nil
    }
    
    func dismiss() {
        selectedSheetModel = nil
    }
}

struct CollectionEditorViewUI_Previews: PreviewProvider {
    @State static var showingCollectionEditor: CollectionsViewUI.CollectionEditor? = nil
    static var previews: some View {
        CollectionEditorViewUI(cluster: nil, showingCollectionEditor: $showingCollectionEditor)
    }
}
