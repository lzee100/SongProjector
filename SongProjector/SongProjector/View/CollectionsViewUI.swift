//
//  CollectionsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class MusicDownloadManager: ObservableObject {
    
    @Published private(set) var musicDownloaders: [FetchMusicUseCase] = []
    
    func downloadMusicFor(collection: ClusterCodable) async throws {
        guard !musicDownloaders.contains(where: { $0.id == collection.id }) else { return }
        let fetchMusicUseCase = FetchMusicUseCase(collection: collection)
        musicDownloaders.append(fetchMusicUseCase)
        try await fetchMusicUseCase.fetch()
        musicDownloaders.removeAll(where: { $0.id == collection.id })
    }
    
    func isDownloading(for collection: ClusterCodable) async -> Bool {
        musicDownloaders.contains(where: { $0.id == collection.id })
    }

}

@MainActor class CollectionsViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    
    @Published var error: LocalizedError?
    @Published var showDeletedCollections = false
    @Published private(set) var collections: [ClusterCodable] = []
    private var unfilteredCollections: [ClusterCodable] = []
    @Published private(set) var showingLoader = false
    @ObservedObject var tagSelectionModel: TagSelectionModel = TagSelectionModel(mandatoryTags: [])
    private let customSelectionDelegate: CollectionsViewCustomSelectionDelegate?
    @Published private var customSelectedSongsForSongService: [ClusterCodable] = []
    var hasCustomSelectedSongsForSongService: Bool {
        return customSelectionDelegate != nil
    }
    init(
        tagSelectionModel: TagSelectionModel,
        customSelectedSongsForSongService: [ClusterCodable],
        customSelectionDelegate: CollectionsViewCustomSelectionDelegate?
    ) {
        self.tagSelectionModel = tagSelectionModel
        self.customSelectedSongsForSongService = customSelectedSongsForSongService
        self.customSelectionDelegate = customSelectionDelegate
    }
    
    func fetchCollections(searchText: String? = nil) async {
        let searchText = searchText?.isBlanc ?? true ? self.searchText.isBlanc ? nil : self.searchText : searchText
        self.searchText = searchText ?? ""
        if unfilteredCollections.count > 0 {
            collections = await FilteredCollectionsUseCase.getCollectionsIn(collections: unfilteredCollections, searchText: searchText, selectedTags: (tagSelectionModel.selectedTags + tagSelectionModel.mandatoryTags).unique, showDeleted: showDeletedCollections)
            return
        }
        collections = await FilteredCollectionsUseCase.getCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: (tagSelectionModel.selectedTags +  tagSelectionModel.mandatoryTags).unique)
    }
    
    func reload() async {
        let searchText = self.searchText.isBlanc ? nil : self.searchText
        unfilteredCollections = await FilteredCollectionsUseCase.getCollections(searchText: nil, showDeleted: true, selectedTags: [])

        collections = await FilteredCollectionsUseCase.getCollectionsIn(collections: unfilteredCollections, searchText: searchText, selectedTags: (tagSelectionModel.selectedTags +  tagSelectionModel.mandatoryTags).unique, showDeleted: showDeletedCollections)
    }
    
    func fetchRemoteTags() async {
        guard !showingLoader else { return }
        
        showingLoader = true
        
        await reload()
        await tagSelectionModel.fetchRemoteTags()
        showingLoader = false
    }
    
    func fetchRemoteThemes() async {
        guard !showingLoader else { return }
        
        showingLoader = true
        
        await reload()
        do {
            let newThemes = try await FetchThemesUseCase(fetchAll: false).fetch()
            showingLoader = false
            if newThemes.count > 0 {
                await fetchRemoteThemes()
            }
        } catch {
            self.showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func fetchRemoteCollections() async {
        guard !showingLoader else { return }
        showingLoader = true
        do {
            let newCollections = try await FetchCollectionsUseCase(fetchAll: false).fetch()
            if newCollections.count > 0 {
                showingLoader = false
                await fetchRemoteCollections()
            } else {
                await reload()
                showingLoader = false
            }
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func deleteMusicFor(_ cluster: ClusterCodable) async {
        showingLoader = true
        do {
            try await DeleteLocalMusicUseCase(cluster: cluster).delete()
            await reload()
            showingLoader = false
        } catch {
            self.error = error as? LocalizedAlertError ?? RequestError.unknown(requester: "", error: error)
            showingLoader = false
        }
    }
        
    func restore(_ collection: ClusterCodable) async {
        showingLoader = true
        var collection = collection
        collection.deleteDate = nil
        if uploadSecret == nil {
            collection.rootDeleteDate = nil
        }
        do {
            try await SubmitUseCase(endpoint: .clusters, requestMethod: .put, uploadObjects: [collection]).submit()
            await reload()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
        
    }
    
    func delete(_ collection: ClusterCodable) async {
        showingLoader = true
        var collection = collection
        collection.deleteDate = Date()
        if uploadSecret != nil {
            collection.rootDeleteDate = Date()
        }
        do {
            try await SubmitUseCase(endpoint: uploadSecret == nil ? .clusters : .universalclusters, requestMethod: .delete, uploadObjects: [collection]).submit()
            await reload()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func didSelectCustomSongForSongService(collection: ClusterCodable) {
        if let index = customSelectedSongsForSongService.firstIndex(of: collection) {
            customSelectedSongsForSongService.remove(at: index)
        } else {
            customSelectedSongsForSongService.append(collection)
        }
    }
    
    func isCustomSelectionSelected(_ collection: ClusterCodable) -> Bool {
        customSelectedSongsForSongService.contains(collection)
    }

    func didSelectFinishCustomSelectionSongsForSongService() {
        customSelectionDelegate?.didFinishCustomSelection(collections: customSelectedSongsForSongService)
    }
}

protocol CollectionsViewCustomSelectionDelegate{
    func didFinishCustomSelection(collections: [ClusterCodable])
}
struct CollectionsViewUI: View {
    
    enum CollectionEditor: Identifiable {
        case new(type: CollectionEditorViewModel.CollectionType)
        case existing(ClusterCodable)
        
        var id: String {
            switch self {
            case .new: return "new"
            case .existing(let cluster): return cluster.id
            }
        }
    }
    
    enum AlertMessage: Identifiable {
        var id: String {
            switch self {
            case .delete: return UUID().uuidString
            case .deleteMusic: return UUID().uuidString
            }
        }
        case delete(ClusterCodable)
        case deleteMusic(ClusterCodable)
        
        var message: String {
            switch self {
            case .delete(let collection): return AppText.Songs.deleteBody(songName: collection.title ?? "")
            case .deleteMusic(let collection): return AppText.Songs.deleteMusicBody(songName: collection.title ?? "")
            }
        }
    }
    
    @Binding var editingSection: SongServiceSectionWithSongs?
    @ObservedObject var songServiceEditorModel: SongServiceEditorModel
    @StateObject var viewModel: CollectionsViewModel
    @StateObject var tagSelectionModel = TagSelectionModel(mandatoryTags: [])
    @State var showingCollectionEditor: CollectionEditor?
    @State var alertMessage: AlertMessage? = nil
    @State var showingTrailingButtonAlertMessage = false
    @EnvironmentObject var musicDownloadManager: MusicDownloadManager

    @State private var selectedCollectionForTrailingActions: ClusterCodable? = nil
    @SwiftUI.Environment(\.colorScheme) var colorScheme

    init(
        editingSection: Binding<SongServiceSectionWithSongs?>,
        songServiceEditorModel: SongServiceEditorModel,
        customSelectedSongsForSongService: [ClusterCodable] = [],
        customSelectionDelegate: CollectionsViewCustomSelectionDelegate? = nil,
        mandatoryTags: [TagCodable]
    ) {
        self._editingSection = editingSection
        self.songServiceEditorModel = songServiceEditorModel
        let model = TagSelectionModel(mandatoryTags: mandatoryTags, addDeleteTag: UIDevice.current.userInterfaceIdiom == .phone)
        _tagSelectionModel = StateObject(wrappedValue: model)
        self._viewModel = StateObject(wrappedValue: CollectionsViewModel(
            tagSelectionModel: model,
            customSelectedSongsForSongService: customSelectedSongsForSongService,
            customSelectionDelegate: customSelectionDelegate
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    TagSelectionScrollViewUI(viewModel: viewModel.tagSelectionModel)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        Button {
                            viewModel.showDeletedCollections.toggle()
                        } label: {
                            Text(AppText.Tags.deletedClusters)
                        }
                        .styleAsSelectionCapsuleButton(isSelected: viewModel.showDeletedCollections)
                    }
                }
                .padding()
                
                List {
                    ForEach(viewModel.collections, id: \.listViewID) { collection in
                        Button {
                            if let editingSection {
                                songServiceEditorModel.change(collection, to: editingSection)
                                self.editingSection = nil
                            } else if songServiceEditorModel.isInUsage {
                                viewModel.didSelectCustomSongForSongService(collection: collection)
                            } else {
                                showingCollectionEditor = .existing(collection)
                            }
                        } label: {
                            CollectionListViewUI(
                                collectionsViewModel: viewModel,
                                collection: collection,
                                isSelectable: songServiceEditorModel.isInUsage,
                                isSelected: (editingSection?.selectedCollectionIds.contains(where: { $0 == collection.id }) ?? false) ||  viewModel.isCustomSelectionSelected(collection)
                            )
                            .frame(minHeight: 50)
                        }
                        .buttonStyle(.borderless)
                        .tint(.black.opacity(0.8))
                        .swipeActions {
                            if viewModel.showDeletedCollections {
                                restore(collection: collection)
                            } else {
                                deleteSongButton(collection: collection)
                                if collection.hasLocalMusic {
                                    deleteLocalMusicButton(collection: collection)
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    await viewModel.fetchRemoteCollections()
                }
            }
            .errorAlert(error: $viewModel.error)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(AppText.Songs.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if viewModel.hasCustomSelectedSongsForSongService {
                        Button {
                            viewModel.didSelectFinishCustomSelectionSongsForSongService()
                        } label: {
                            Text(AppText.Actions.done)
                            .tint(Color(uiColor: themeHighlighted))
                        }
                    }
                    if editingSection != nil {
                        Button {
                            editingSection = nil
                        } label: {
                            Text(AppText.Actions.cancel)
                            .tint(Color(uiColor: themeHighlighted))
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    ProgressView()
                        .tint(Color(uiColor: .blackColor).opacity(0.8))
                        .opacity(viewModel.showingLoader ? 1 : 0)
                    
                   menu

                }
            }
            .background(Color(uiColor: colorScheme == .dark ? .black : .systemGray6))
            .searchable(text: $viewModel.searchText).tint(Color(uiColor: themeHighlighted))
            .autocorrectionDisabled()
        }
        .task {
            await viewModel.fetchRemoteTags()
            await viewModel.fetchRemoteThemes()
            await viewModel.fetchRemoteCollections()
        }
        .onChange(of: viewModel.searchText, perform: { searchText in
            Task(priority: .high) {
                await viewModel.fetchCollections(searchText: searchText)
            }
        })
        .onChange(of: viewModel.tagSelectionModel.selectedTags, perform: { selectedTags in
            Task(priority: .high) {
                await viewModel.fetchCollections()
            }
        })
        .onChange(of: viewModel.showDeletedCollections, perform: { showDeletedCollections in
            Task(priority: .high) {
                await viewModel.fetchCollections()
            }
        })
        .alert(isPresented: $showingTrailingButtonAlertMessage, content: {
            Alert(title: Text(alertMessage!.message), message: nil, primaryButton: Alert.Button.destructive(Text(AppText.Actions.delete), action: {
                Task {
                    switch alertMessage! {
                    case .delete(let collection): await viewModel.delete(collection)
                    case .deleteMusic(let collection): await viewModel.deleteMusicFor(collection)
                    }
                }
            }), secondaryButton: Alert.Button.cancel({
                alertMessage = nil
            }))
        })
        .sheet(item: $showingCollectionEditor, onDismiss: {
            Task {
                await viewModel.reload()
            }
        }, content: { editor in
            switch editor {
            case .new(let collectionType):
                CollectionEditorViewUI(cluster: nil, collectionType: collectionType, showingCollectionEditor: $showingCollectionEditor)
            case .existing(let cluster):
                CollectionEditorViewUI(cluster: cluster, collectionType: cluster.collectionType, showingCollectionEditor: $showingCollectionEditor)
            }
        })
        .onReceive(musicDownloadManager.$musicDownloaders) { _ in
            Task {
                await viewModel.reload()
            }
        }
    }
    
    @ViewBuilder private func deleteLocalMusicButton(collection: ClusterCodable) -> some View {
        Button {
            alertMessage = .deleteMusic(collection)
            showingTrailingButtonAlertMessage = true
        } label: {
            Image("TrashMusic")
                .resizable()
                .tint(.white)
        }
        .tint(Color(uiColor: .red2))
    }
    
    @ViewBuilder private func deleteSongButton(collection: ClusterCodable) -> some View {
        Button {
            alertMessage = .delete(collection)
            showingTrailingButtonAlertMessage = true
        } label: {
            Label {
                Text(AppText.Actions.delete)
            } icon: {
                Image(systemName: "trash")
                    .tint(.white)
            }
        }
        .tint(Color(uiColor: .red1))
    }
    
    @ViewBuilder private func restore(collection: ClusterCodable) -> some View {
        Button {
            Task {
                await viewModel.restore(collection)
            }
        } label: {
            Text(AppText.Actions.restore)
        }
        .tint(Color(uiColor: .green1))
    }
    
    @ViewBuilder private var menu: some View {
        Menu {
            ForEach(CollectionEditorViewModel.CollectionType.allCases, id: \.self) { collectionType in
                Button {
                    showingCollectionEditor = .new(type: collectionType)
                } label: {
                    Text(collectionType.title)
                }
            }
        } label: {
            Image(systemName: "plus")
                .tint(Color(uiColor: themeHighlighted))
        }
    }
    
}

fileprivate extension ClusterCodable {
    var collectionType: CollectionEditorViewModel.CollectionType {
        if self.isTypeSong {
            return .lyrics
        } else if self.hasBibleVerses {
            return .bibleStudy
        }
        return .custom
    }
}
