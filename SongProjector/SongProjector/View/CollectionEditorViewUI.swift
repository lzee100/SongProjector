//
//  CollectionEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

class SheetSizeClass: ObservableObject {
    @Published var sheetSize: CGSize = .zero
}

struct InstrumentsModel {
    struct Instrument: Identifiable {
        var resourcePath: URL?
        let id = UUID()
        let instrumentType: InstrumentType
        var uploadObject: UploadObject?
    }
    
    var instruments: [Instrument]
    
    init() {
        instruments = InstrumentType.all.map { Instrument(instrumentType: $0) }
    }
}

struct CollectionEditorViewUI: View {
    
    enum SheetPresentMode: Identifiable {
        var id: String {
            switch self {
            case .bibleStudySheets: return "0"
            }
        }
        
        case bibleStudySheets(content: String)
    }
    @EnvironmentObject var musicDownloadManager: MusicDownloadManager

    @StateObject private var viewModel: CollectionEditorViewModel
    @StateObject private var themeSelectionModel: ThemesSelectionModel
    @StateObject private var tagsSelectionModel: TagSelectionModel
    
    @Binding var showingCollectionEditor: CollectionsViewUI.CollectionEditor?
    @StateObject private var sheetSizeClass = SheetSizeClass()
    @State private var sheetPresentMode: SheetPresentMode? = nil
    @State private var selectedSheetModel: SheetViewModel?
    @State private var isShowingLosingOtherSheetsAlert = false
    @State private var showingTagsExplainedPopOver = false
    @State private var showingTimeExplainedPopOver = false
    @State private var showingDocumentPicker = false
    @State private var selectedInstrumentIndex = 0
    @State private var showingSheetTimesEditorView = false
    @State private var showingSongServicePreview = false
    @State private var showingConfirmUploadUniversalClusterAlert = false
    @State private var generatedPreviewCluster: ClusterCodable?

    init?(
        cluster: ClusterCodable?,
        collectionType: CollectionEditorViewModel.CollectionType,
        showingCollectionEditor: Binding<CollectionsViewUI.CollectionEditor?>
    ) {
        let themesSelectionModel = ThemesSelectionModel(selectedTheme: cluster?.theme)
        let tagsSelectionModel = TagSelectionModel(mandatoryTags: [], selectedTags: cluster?.hasTags ?? [])
        guard let viewModel = CollectionEditorViewModel(cluster: cluster, themeSelectionModel: themesSelectionModel, tagsSelectionModel: tagsSelectionModel, collectionType: collectionType) else {
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

                    titleTextField

                    if uploadSecret != nil {
                        TextFieldViewUI(textFieldViewModel: TextFieldViewModel(
                            label: nil,
                            placeholder: "Start time",
                            characterLimit: TextFieldViewModel.CharacterLimit.standaard.rawValue,
                            text: $viewModel.clusterStartTime
                        ))
                    }
                    tagSelectionRowView

                    if viewModel.collectionType == .bibleStudy {
                        Toggle(AppText.NewSong.emptySheetAfterBibleStudyText, isOn: $viewModel.cluster.showEmptySheetBibleText)
                    }

                    if viewModel.showTimePickerScrollView {
                        clusterSheettimeRowView
                    }
                }
                
                Section {
                    ThemesScrollViewUI(model: viewModel.themeSelectionModel)
                    sheets
                }
                
                if uploadSecret != nil, !viewModel.sheets.contains(where: { $0.sheetEditType != .lyrics }) {
                    Section {
                        instrumentSelectorViews
                    }
                }
            }
            .blur(radius: viewModel.showingLoader ? 5 : 0)
            .overlay {
                if viewModel.showingLoader {
                    ProgressView()
                        .scaleEffect(1.4)
                }
            }
            .listStyle(.grouped)
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
                    if uploadSecret != nil {
                        universalClusterUploadOptions
                    } else {
                        editButtonsFor(viewModel.editActions)
                    }
                }
            })
            .sheet(item: $sheetPresentMode, content: { sheetPresenter in
                switch sheetPresenter {
                case .bibleStudySheets(let content):
                    LyricsOrBibleStudyInputViewUI(viewModel: LyricsOrBibleStudyInputViewModel(
                        originalContent: content,
                        content: $viewModel.lyricsOrBibleStudyText,
                        cluster: viewModel.cluster,
                        font: .body,
                        collectionType: viewModel.collectionType,
                        delegate: self,
                        sheetPresentMode: $sheetPresentMode,
                        isNewSong: uploadSecret != nil
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
            .sheet(isPresented: $showingSheetTimesEditorView, content: {
                SheetTimesEditViewUI(
                    sheetTimesEditorStringValue: viewModel.sheets.compactMap { $0.sheetTime.isBlanc ? nil : $0.sheetTime }.joined(separator: "\n"),
                    showingSheetTimesEditView: $showingSheetTimesEditorView,
                    delegate: self)
            })
            .fullScreenCover(isPresented: $showingSongServicePreview, content: {
                return SongServiceViewUI(
                    previewSong: try? viewModel.generatePreviewCluster(), // FIXME: if error, this is shown while prezenting this screen, this goes totally wrong. TODO: ...
                    showingSongServiceView: $showingSongServicePreview
                )
            })
        }
        .environmentObject(musicDownloadManager)
        .interactiveDismissDisabled()
        .alert(AppText.UploadUniversalSong.saveClusterConformationQuestion, isPresented: $showingConfirmUploadUniversalClusterAlert, actions: {
            Button(role: .destructive) {
                Task {
                    if await viewModel.saveCluster() {
                        showingCollectionEditor = nil
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(AppText.Actions.save)
                }
            }
            Button("Cancel", role: .cancel) { }
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
        .fullScreenCover(isPresented: $showingDocumentPicker, onDismiss: {
            selectedInstrumentIndex = 0
        }, content: {
            DocumentPickerViewUI(fileURL: $viewModel.instrumentsModel.instruments[selectedInstrumentIndex].resourcePath, showingDocumentPicker: $showingDocumentPicker)
        })
        .onChange(of: viewModel.themeSelectionModel.selectedTheme, perform: { _ in
            viewModel.updateSheets(sheetSize: sheetSizeClass.sheetSize)
        })
        .onChange(of: viewModel.lyricsOrBibleStudyText) { text in
            if viewModel.collectionType == .bibleStudy {
                Task {
                    await viewModel.bibleStudyTextDidChange(
                        lyricsOrBibleStudytext: text,
                        updateExistingSheets: false,
                        parentViewSize: sheetSizeClass.sheetSize
                    )
                }
            } else if viewModel.collectionType == .lyrics {
                Task {
                    await viewModel.lyricsTextDidChange(screenWidth: sheetSizeClass.sheetSize.width)
                }
            }
        }
        .onChange(of: viewModel.cluster.showEmptySheetBibleText, perform: { _ in
            Task {
                await viewModel.bibleStudyTextDidChange(lyricsOrBibleStudytext: viewModel.lyricsOrBibleStudyText, updateExistingSheets: false, parentViewSize: sheetSizeClass.sheetSize)
            }
        })
        .task {
            await viewModel.tagsSelectionModel.fetchRemoteTags()
        }
    }
    
    @ViewBuilder var titleTextField: some View {
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
        .observeViewSize()
        .onPreferenceChange(SizePreferenceKey.self) { size in
            self.sheetSizeClass.sheetSize = size
            print(size)
            if viewModel.collectionType == .bibleStudy {
                Task {
                    await viewModel.bibleStudyTextDidChange(
                        lyricsOrBibleStudytext: viewModel.lyricsOrBibleStudyText,
                        updateExistingSheets: true,
                        parentViewSize: sheetSizeClass.sheetSize
                    )
                }
            }
        }
    }
    
    @ViewBuilder var sheets: some View {
        switch viewModel.collectionType {
        case .bibleStudy:
            bibleStudySheets()
        case .lyrics, .custom:
            ForEach(Array(zip(viewModel.sheets.indices, viewModel.sheets)), id: \.0) { index, sheetModel in
                VStack {
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
                    if uploadSecret != nil {
                        TextField(text: $viewModel.sheets[index].sheetTime) {
                            Text("Time")
                        }
                        .padding([.top], 5)
                        .keyboardType(.numberPad)
                    }
                }
                .moveDisabled(viewModel.canMove(sheetModel))
            }
            .onMove { source, destination in
                viewModel.move(from: source, to: destination)
            }
            .listRowSeparator(.hidden)
        }
    }
    
    @ViewBuilder func bibleStudySheets() -> some View {
        ForEach(viewModel.sheets) { sheetModel in
            SheetUIHelper.sheet(sheetViewModel: sheetModel, isForExternalDisplay: false)
                .onTapGesture {
                    Task {
                        let text = await viewModel.getBibleStudyString()
                        await MainActor.run(body: {
                            sheetPresentMode = .bibleStudySheets(content: text)
                        })
                    }
                }
                .overlay {
                    if viewModel.canDelete(sheetViewModel: sheetModel) {
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
            viewModel.move(from: source, to: destination)
        }
        .listRowSeparator(.hidden)
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
    
    @ViewBuilder func editButtonsFor(_ editActions: [CollectionEditorViewModel.MenuItem]) -> some View {
        HStack {
            ForEach(editActions) { editAction in
                switch editAction {
                case .save:
                    Button {
                        Task {
                            if await viewModel.saveCluster() {
                                showingCollectionEditor = nil
                            }
                        }
                    } label: {
                        Text(AppText.Actions.save)
                    }
                case .add:
                    Button {
                        viewModel.themeSelectionModel.selectFirstthemeIfNeeded()
                        sheetPresentMode = .bibleStudySheets(content: "")
                    } label: {
                        Image(systemName: "plus")
                    }
                case .change:
                    Button {
                        Task {
                            let text = viewModel.getLyricsString()
                            sheetPresentMode = .bibleStudySheets(content: text)
                        }
                    } label: {
                        Text(AppText.Actions.change)
                    }
                case .menu:
                    customSheetsMenu
                }
            }
            .tint(Color(uiColor: themeHighlighted))
            .disabled(viewModel.showingLoader)
        }
    }
    
    @ViewBuilder var universalClusterUploadOptions: some View {
        Menu {
            if uploadSecret != nil {
                Menu(AppText.NewSong.Menu.sheets, content: {
                        Button {
                            sheetPresentMode = .bibleStudySheets(content: "")
                        } label: {
                            Text("Lyrics")
                        }
                        Button {
                            Task {
                                do {
                                    let selectedSheetModel = try await SheetType.SheetPastors.sheetModel(with: viewModel.cluster)
                                    self.selectedSheetModel = selectedSheetModel
                                } catch {
                                    viewModel.error = error.forcedLocalizedError
                                }
                            }
                        } label: {
                            Text("Pastors")
                        }
                 })
            } else {
                Button {
                    sheetPresentMode = .bibleStudySheets(content: "")
                } label: {
                    Text("Lyrics")
                }
            }
            Button {
                showingSheetTimesEditorView = true
            } label: {
                Text(AppText.NewSong.Menu.changeTimes)
            }
            Button {
                generatedPreviewCluster = try? viewModel.generatePreviewCluster()
                showingSongServicePreview = true
            } label: {
                Text(AppText.NewSong.Menu.showPreview)
            }
            Button {
                showingConfirmUploadUniversalClusterAlert = true
            } label: {
                Text(AppText.NewSong.Menu.upload)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .tint(Color(uiColor: themeHighlighted))
        }
        .disabled(viewModel.showingLoader)
    }
        
    @ViewBuilder private var instrumentSelectorViews: some View {
            ForEach(Array(zip(viewModel.instrumentsModel.instruments.indices, viewModel.instrumentsModel.instruments)), id: \.0) { index, instrument in
                HStack {
                    Text(instrument.instrumentType.rawValue)
                    Spacer()
                    Button {
                        selectedInstrumentIndex = index
                        showingDocumentPicker = true
                    } label: {
                        if instrument.resourcePath == nil {
                            Text("Select file")
                                .foregroundColor(Color(uiColor: themeHighlighted))
                        } else {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color(uiColor: .green1))
                        }
                    }

                }
            }
    }
    
    private var customSheetsMenu: some View {
        Menu {
            if viewModel.collectionType == .bibleStudy {
                Section {
                    Button(AppText.Lyrics.titleBibleText) {
                        viewModel.themeSelectionModel.selectFirstthemeIfNeeded()
                        sheetPresentMode = .bibleStudySheets(content: "")
                    }
                }
            }
            Section {
                ForEach(SheetType.all, id: \.rawValue) { type in
                    Button(type.name) {
                        Task {
                            do {
                                let selectedSheetModel = try await type.sheetModel(with: viewModel.cluster)
                                await MainActor.run {
                                    self.selectedSheetModel = selectedSheetModel
                                }
                            } catch {
                                viewModel.error = error.forcedLocalizedError
                            }
                        }
                    }
                }
            }
        } label: {
            Label(AppText.Actions.add, systemImage: "plus")
                .tint(Color(uiColor: themeHighlighted))
        }
        .tint(Color(uiColor: themeHighlighted))
    }
}

extension CollectionEditorViewUI: SheetTimesEditViewDelegate {
    func didUpdateSheetTimes(value: String) {
        let times = GetSheetTimesEditUseCase.getTimesFrom(value, sheetViewModels: viewModel.sheets)
        for index in 0..<times.count {
            if index < viewModel.sheets.count {
                viewModel.sheets[index].sheetTime = times[index]
            }
        }
        showingSheetTimesEditorView = false
    }
}

extension CollectionEditorViewUI: LyricsOrBibleStudyInputViewModelDelegate {
    
    func didSave(content: String) {
        viewModel.lyricsOrBibleStudyText = content
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
        CollectionEditorViewUI(cluster: nil, collectionType: .custom, showingCollectionEditor: $showingCollectionEditor)
    }
}

private extension SheetType {
    func sheetModel(with cluster: ClusterCodable) async throws -> SheetViewModel? {
        let defaultTheme = try await CreateThemeUseCase().create(isHidden: true)
        var sheet = await self.makeDefault()
        sheet = sheet?.set(theme: defaultTheme)
        if let sheet = sheet {
            return try await SheetViewModel(cluster: cluster, theme: sheet.theme, defaultTheme: defaultTheme, sheet: sheet, sheetType: self, sheetEditType: .custom)
        } else {
            return nil
        }
    }
}
