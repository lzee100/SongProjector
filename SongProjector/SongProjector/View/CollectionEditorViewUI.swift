//
//  CollectionEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct CollectionEditorViewUI: View {
    
    @StateObject private var viewModel: CollectionEditorViewModel
    @StateObject private var themeSelectionModel: ThemesSelectionModel
    @StateObject private var tagsSelectionModel: TagSelectionModel
    
    @Binding var showingCollectionEditor: CollectionsViewUI.CollectionEditor?
    @State private var lyricsOrBibleStudyText: String = ""
    @State private var sheetSize: CGSize = .zero
    @State private var isShowingLyricsOrBibleStudyInputView = false
    @State private var selectedSheetModel: WrappedStruct<EditSheetOrThemeViewModel>?
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
                    clusterSheettimeRowView
                }
                
                Section {
                    ThemesScrollViewUI(model: viewModel.themeSelectionModel)
                    sheets
                }
                .onPreferenceChange(SizePreferenceKey.self) { size in
                    self.sheetSize = size
                    if viewModel.collectionType.isBibleStudy {
                        viewModel.bibleStudyTextDidChange(lyricsOrBibleStudyText, contentTextViewContentSize: .zero
                                                           , scaleFactor: getScaleFactor(width: size.width))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(AppText.NewSong.title)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(AppText.Actions.close) {
                        showingCollectionEditor = nil
                    }
                    .tint(Color(uiColor: themeHighlighted))
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if viewModel.sheets.count > 0 {
                        Button {
                            viewModel.saveCluster()
                        } label: {
                            Text(AppText.Actions.save)
                        }
                        .tint(Color(uiColor: themeHighlighted))
                    }
                    menu
                }
            })
            
        }
        .onAppear {
            if [.bibleStudy, .lyrics].contains(viewModel.collectionType) {
                lyricsOrBibleStudyText = viewModel.getLyricsOrBibleStudyString()
            }
        }
        .sheet(isPresented: $isShowingLyricsOrBibleStudyInputView) {
            LyricsOrBibleStudyInputViewUI(content: $lyricsOrBibleStudyText, isShowingLyricsOrBibleStudyInputView: $isShowingLyricsOrBibleStudyInputView)
        }
        .sheet(item: $selectedSheetModel, content: { model in
            EditThemeOrSheetViewUI(navigationTitle: AppText.SheetPickerMenu.pickCustom, delegate: self, editingCollectionModel: self.viewModel, editSheetOrThemeModel: model)
        })
        .alert(AppText.CustomSheets.errorSelectTheme, isPresented: $isShowingNoThemeSelectedAlert, actions: {
            Button("OK", role: .cancel) { }
        })
        .alert(AppText.CustomSheets.errorChangeSheetGenerator, isPresented: $isShowingChangeEditControllerTypeAlert, actions: {
            Button(AppText.Actions.continue, role: .destructive) {
                lyricsOrBibleStudyText = ""
                if viewModel.collectionType.isBibleStudy {
                    viewModel.collectionType = .lyrics
                } else {
                    viewModel.collectionType = .bibleStudy
                }
                isShowingLyricsOrBibleStudyInputView.toggle()
            }
            Button(AppText.Actions.cancel, role: .cancel) { }
        })
        .alert(AppText.CustomSheets.errorLoseOtherSheets, isPresented: $isShowingLosingOtherSheetsAlert, actions: {
            Button(AppText.Actions.continue, role: .destructive) {
                lyricsOrBibleStudyText = ""
                isShowingLyricsOrBibleStudyInputView.toggle()
            }
            Button(AppText.Actions.cancel, role: .cancel) { }
        })
        .onChange(of: viewModel.themeSelectionModel.selectedTheme, perform: { theme in
            viewModel.updateSheets()
        })
        .onChange(of: lyricsOrBibleStudyText) { newValue in
            if viewModel.collectionType.isBibleStudy {
                viewModel.bibleStudyTextDidChange(newValue, contentTextViewContentSize: .zero, scaleFactor: getScaleFactor(width: sheetSize.width))
            } else {
                viewModel.lyricsTextDidChange(newValue, screenWidth: sheetSize.width)
            }
        }
    }
    
    @ViewBuilder var sheets: some View {
        switch viewModel.collectionType {
        case .bibleStudy:
            bibleStudySheets()
        case .lyrics, .customSheet, .none:
                ForEach(viewModel.sheets) { sheetModel in
                    Button {
                        if viewModel.collectionType == .lyrics {
                            isShowingLyricsOrBibleStudyInputView.toggle()
                        } else {
                            selectedSheetModel = WrappedStruct(withItem: sheetModel)
                        }
                    } label: {
                        SheetUIHelper.sheet(editSheetOrThemeModel: WrappedStruct(withItem: sheetModel), isForExternalDisplay: false)
                            .observeViewSize()
                    }
                    .buttonStyle(.borderless)
                    .overlay {
                        if !viewModel.cluster.isTypeSong {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        viewModel.sheets.removeAll(where: { $0.id == sheetModel.id })
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
        VStack {
            if lyricsOrBibleStudyText.count > 0 {
                ForEach(viewModel.sheets) { sheetModel in
                    SheetUIHelper.sheet(editSheetOrThemeModel: WrappedStruct(withItem: sheetModel), isForExternalDisplay: false, calculateBibleStudyContentSizeForSheetSize: sheetSize)
                        .observeViewSize()
                        .onTapGesture {
                            isShowingLyricsOrBibleStudyInputView.toggle()
                        }
                }
            }
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
    
    private var menu: some View {
        Menu {
            Section {
                Button(AppText.SheetsMenu.lyrics) {
                    if viewModel.themeSelectionModel.selectedTheme == nil {
                        isShowingNoThemeSelectedAlert = true
                    } else if ![.none, .lyrics].contains(viewModel.collectionType) && lyricsOrBibleStudyText.count > 0 {
                        isShowingChangeEditControllerTypeAlert.toggle()
                    } else {
                        viewModel.collectionType = .lyrics
                        isShowingLyricsOrBibleStudyInputView.toggle()
                    }
                }
            }
            Section {
                ForEach(SheetType.all, id: \.rawValue) { type in
                    Button(type.name) {
                        viewModel.collectionType = .customSheet(type: type)
                        self.selectedSheetModel = viewModel.customSheetsEditModel
                    }
                }
            }
            Section {
                Button(AppText.Lyrics.titleBibleText) {
                    if viewModel.themeSelectionModel.selectedTheme == nil {
                        isShowingNoThemeSelectedAlert = true
                    } else if ![.none, .bibleStudy].contains(viewModel.collectionType) && lyricsOrBibleStudyText.count > 0 {
                        isShowingChangeEditControllerTypeAlert.toggle()
                    } else if ![.none, .bibleStudy].contains(viewModel.collectionType) && viewModel.sheets.count > 0 {
                        isShowingLosingOtherSheetsAlert.toggle()
                    } else {
                        viewModel.collectionType = .bibleStudy
                        isShowingLyricsOrBibleStudyInputView.toggle()
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
