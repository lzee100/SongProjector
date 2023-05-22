//
//  CollectionsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

actor MusicDownloadManager: ObservableObject {
    
    @Published private var musicDownloaders: [FetchMusicUseCase] = []
    
    func downloadMusicFor(collection: ClusterCodable) async throws {
        guard musicDownloaders.contains(where: { $0.id != collection.id }) else { return }
        let fetchMusicUseCase = FetchMusicUseCase(cluster: collection)
        musicDownloaders.append(fetchMusicUseCase)
        try await fetchMusicUseCase.fetch()
        musicDownloaders.removeAll(where: { $0.id == collection.id })
    }

    func isDownloading(for cluster: ClusterCodable) async -> Bool {
        musicDownloaders.contains(where: { $0.id == cluster.id })
    }

}

@MainActor class CollectionsViewModel: ObservableObject {
    
    @Published var error: LocalizedError?
    
    @Published private(set) var collections: [ClusterCodable] = []
    @Published private(set) var showingLoader = false
    
    private var searchText: String? = nil
    private var showDeleted = false
    private var selectedTags: [TagCodable] = []
    
    
    init() {
        Task {
            await reload()
        }
    }
    
    func fetchCollections(searchText: String? = nil, showDeleted: Bool = false, selectedTags: [TagCodable] = []) async {
        collections = await FilteredCollectionsUseCase().getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
        self.searchText = searchText
        self.showDeleted = showDeleted
        self.selectedTags = selectedTags
    }
    
    func reload() async {
        collections = await FilteredCollectionsUseCase().getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
    }
    
    func fetchRemoteThemes() async {
        guard !showingLoader else { return }
        showingLoader = true
        await reload()
        do {
            try await FetchThemesUseCase(fetchAll: false).fetch()
            self.showingLoader = false
        } catch {
            self.showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func fetchRemoteCollections() async {
        guard !showingLoader else { return }
        await reload()
        showingLoader = true
        do {
            collections = try await FetchCollectionsUseCase(fetchAll: false).fetch()
            showingLoader = false
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
        if uploadSecret == nil {
            collection.rootDeleteDate = Date()
        }
        do {
            try await SubmitUseCase(endpoint: uploadSecret == nil ? .clusters : .universalclusters, requestMethod: .put, uploadObjects: [collection]).submit()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
}

struct CollectionsViewUI: View {
    
    enum CollectionEditor: Identifiable {
        case new
        case existing(ClusterCodable)
        
        var id: String {
            switch self {
            case .new: return "new"
            case .existing(let cluster): return cluster.id
            }
        }
    }
    
    let editingSection: SongServiceSectionWithSongs?
    @ObservedObject var songServiceEditorModel: WrappedOptionalStruct<SongServiceEditorModel>
    @EnvironmentObject private var soundPlayer: SoundPlayer2
    @State var showingCollectionsViewUI: Binding<Bool>? = nil
    @State var mandatoryTags: [TagCodable] = []
    @StateObject var viewModel = CollectionsViewModel()
    @StateObject var tagSelectionModel = TagSelectionModel(mandatoryTags: [])

    @State private var showingDeleteLocalMusicAlert = false
    @State private var showingDoYouWantToDeleteSongAlert = false
    @State private var deleteLocalMusicError: Error?
    @State private var networkError: Error?
    @State private var selectedCollectionForTrailingActions: ClusterCodable?
    @State private var showingCollectionEditor: CollectionEditor?
    @State private var showDeletedCollections = false
    @State private var searchText = ""
    
    private var allowsRowSelection: Bool {
        if songServiceEditorModel.item != nil {
            return editingSection == nil
        } else {
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TagSelectionScrollViewUI(viewModel: tagSelectionModel)
                    Button {
                        showDeletedCollections.toggle()
                    } label: {
                        Text(AppText.Tags.deletedClusters)
                    }
                    .styleAsSelectionCapsuleButton(isSelected: showDeletedCollections)
                }
                .padding([.top, .leading, .trailing])
                if viewModel.showingLoader {
                    ProgressView()
                        .padding([.top, .leading, .trailing])
                        .tint(Color(uiColor: .blackColor).opacity(0.8))
                }

                List {
                    if viewModel.showingLoader {
                        ProgressView()
                            .padding()
                            .tint(Color(uiColor: .systemGray5))
                    }
                    ForEach(viewModel.collections, id: \.id) { collection in
                        Button {
                            if let editingSection {
                                songServiceEditorModel.item?.add(collection, to: editingSection)
                            } else if let songServiceEditorModel = songServiceEditorModel.item {
                                songServiceEditorModel.didSelect(collection)
                            } else {
                                showingCollectionEditor = .existing(collection)
                            }
                        } label: {
                            CollectionListViewUI(
                                collectionsViewModel: viewModel,
                                collection: collection,
                                isSelectable: songServiceEditorModel.item != nil,
                                isSelected: songServiceEditorModel.item?.isSelected(collection) ?? false
                            )
                            .frame(minHeight: 50)
                        }
                        .buttonStyle(.borderless)
                        .tint(.black.opacity(0.8))
                        .swipeActions {
                            if showDeletedCollections {
                                restore(collection: collection)
                            } else {
                                deleteSongButtonView(collection: collection)
                                if collection.hasLocalMusic {
                                    deleteLocalContentButtonView(collection: collection)
                                }
                            }
                        }
                        .allowsHitTesting(allowsRowSelection)
                    }
                }
                .padding([.top], 0)
                .refreshable {
                    await viewModel.fetchRemoteCollections()
                }

            }
            .errorAlert(error: $viewModel.error)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(AppText.Songs.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if showingCollectionsViewUI != nil {
                        Button {
                            showingCollectionsViewUI?.wrappedValue.toggle()
                        } label: {
                            Text(AppText.Actions.done)
                            .tint(Color(uiColor: themeHighlighted))
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingCollectionEditor = .new
                    } label: {
                        Label {
                            Text(AppText.Actions.add)
                        } icon: {
                            Image(systemName: "plus")
                        }
                        .tint(Color(uiColor: themeHighlighted))
                    }
                    
                }
            }
            .background(Color(uiColor: .systemGray6))
            .alert(AppText.Songs.deleteMusicBody(songName: "'\(selectedCollectionForTrailingActions?.title ?? "??")'"), isPresented: $showingDeleteLocalMusicAlert) {
                Button(AppText.Actions.delete, role: .destructive) {
                    deleteLocalMusic()
                }
                Button(AppText.Actions.cancel, role: .cancel) {
                    showingDeleteLocalMusicAlert.toggle()
                }
            }
            .alert(AppText.Songs.errorDeletingLocalMusic(error: deleteLocalMusicError?.localizedDescription ?? "-"), isPresented: $showingDeleteLocalMusicAlert) {
                Button(AppText.Actions.ok) {
                    showingDeleteLocalMusicAlert.toggle()
                }
            }
            .alert(AppText.Songs.deleteBody(songName: selectedCollectionForTrailingActions?.title ?? "-"), isPresented: $showingDoYouWantToDeleteSongAlert) {
                Button(AppText.Actions.delete, role: .destructive) {
                    if let selectedCollectionForTrailingActions {
                        Task {
                            await viewModel.delete(selectedCollectionForTrailingActions)
                        }
                    }
                }
                Button(AppText.Actions.cancel, role: .cancel) {
                    showingDoYouWantToDeleteSongAlert.toggle()
                }
            }
            .searchable(text: $searchText).tint(Color(uiColor: themeHighlighted))
        }
        .task {
            await viewModel.fetchRemoteThemes()
            await viewModel.fetchRemoteCollections()
        }
        .onChange(of: searchText, perform: { searchText in
            Task {
                await viewModel.fetchCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
            }
        })
        .onChange(of: tagSelectionModel.selectedTags, perform: { selectedTags in
            Task {
                await viewModel.fetchCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
            }
        })
        .onChange(of: showDeletedCollections, perform: { showDeletedCollections in
            Task {
                await viewModel.fetchCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
            }
        })
        .sheet(item: $showingCollectionEditor, content: { editor in
            switch editor {
            case .new:
                CollectionEditorViewUI(cluster: nil, showingCollectionEditor: $showingCollectionEditor)
            case .existing(let cluster):
                CollectionEditorViewUI(cluster: cluster, showingCollectionEditor: $showingCollectionEditor)
            }
        })
    }
    
    @ViewBuilder private func deleteLocalContentButtonView(collection: ClusterCodable) -> some View {
        Button {
            selectedCollectionForTrailingActions = collection
            showingDeleteLocalMusicAlert.toggle()
        } label: {
            Image("TrashMusic")
                .resizable()
                .tint(.white)
        }
        .tint(Color(uiColor: .red2))
    }
    
    @ViewBuilder private func deleteSongButtonView(collection: ClusterCodable) -> some View {
        Button {
            showingDoYouWantToDeleteSongAlert.toggle()
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
    
    private func deleteLocalMusic() {
        if let selectedCollectionForTrailingActions {
            Task {
                await viewModel.deleteMusicFor(selectedCollectionForTrailingActions)
                
            }
        }
    }
    
}

struct CollectionsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsViewUI(editingSection: nil, songServiceEditorModel: WrappedOptionalStruct<SongServiceEditorModel>(withItem: nil))
    }
}
