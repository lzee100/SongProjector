//
//  CollectionsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class CollectionsViewModel: ObservableObject {
    
    @Published var error: LocalizedError?
    
    @Published private(set) var collections: [ClusterCodable] = []
    @Published private(set) var showingLoader = false
    
    private var searchText: String? = nil
    private var showDeleted = false
    private var selectedTags: [TagCodable] = []

    init() {
        reload()
    }
    func fetchCollections(searchText: String? = nil, showDeleted: Bool = false, selectedTags: [TagCodable] = []) {
        collections = FilteredCollectionsUseCase().getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
        self.searchText = searchText
        self.showDeleted = showDeleted
        self.selectedTags = selectedTags
    }
    
    func reload() {
        collections = FilteredCollectionsUseCase().getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
    }
    
    func fetchRemoteCollections() async {
        reload()
        showingLoader = true
        do {
            let result = try await FetchCollectionsUseCase(fetchAll: false).fetch()
            switch result {
            case .succes(let clusters): saveLocally(clusters)
            case .failed(let error):
                showingLoader = false
                self.error = error
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    private func saveLocally(_ entities: [ClusterCodable]) {
        ManagedObjectContextHandler<ClusterCodable>().save(entities: entities, completion: { [weak self] _ in
            self?.reload()
            if entities.count > 0 {
                Task {
                    await fetchRemoteCollections()
                }
            } else {
                self?.showingLoader = false
            }
        })
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
    let songServiceEditorModel: SongServiceEditorModel?
    @EnvironmentObject private var soundPlayer: SoundPlayer2
    @State var showingCollectionsViewUI: Binding<Bool>? = nil
    @State var mandatoryTags: [TagCodable] = []
    @StateObject var viewModel = CollectionsViewModel()
    @StateObject var tagSelectionModel = TagSelectionModel(mandatoryTags: [])

    @State private var showingDeleteLocalMusicAlert = false
    @State private var showingDoYouWantToDeleteSongAlert = false
    @State private var showingDeleteSongNetworkError = false
    @State private var deleteLocalMusicError: Error?
    @State private var networkError: Error?
    @State private var selectedCollectionForTrailingActions: ClusterCodable?
    @State private var requestProgress: RequesterResult = .idle
    @State private var showingCollectionEditor: CollectionEditor?
    @State private var showDeletedCollections = false
    @State private var searchText = ""
    
    private var allowsRowSelection: Bool {
        if songServiceEditorModel != nil {
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
                List {
                    ForEach(viewModel.collections, id: \.id) { collection in
                        Button {
                            if let editingSection {
                                songServiceEditorModel?.add(collection, to: editingSection)
                            } else if let songServiceEditorModel {
                                songServiceEditorModel.didSelect(collection)
                            } else {
                                showingCollectionEditor = .existing(collection)
                            }
                        } label: {
                            CollectionListViewUI(
                                collectionsViewModel: viewModel,
                                collection: collection,
                                fetchMusicUseCase: FetchMusicUseCase(cluster: collection),
                                isSelectable: songServiceEditorModel != nil,
                                isSelected: songServiceEditorModel?.isSelected(collection) ?? false
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
                    deleteSong()
                }
                Button(AppText.Actions.cancel, role: .cancel) {
                    showingDoYouWantToDeleteSongAlert.toggle()
                }
            }
            .alert(AppText.Songs.errorDeletingSongRemotely(title: selectedCollectionForTrailingActions?.title ?? "??", errorMessage: networkError?.localizedDescription ?? ""), isPresented: $showingDeleteSongNetworkError) {
                Button(AppText.Actions.cancel, role: .cancel) {
                    showingDeleteSongNetworkError.toggle()
                }
            }
            .searchable(text: $searchText).tint(Color(uiColor: themeHighlighted))
        }
        .task {
            await viewModel.fetchRemoteCollections()
        }
        .onChange(of: requestProgress) { newValue in
            switch newValue {
            case .finished(let result):
                switch result {
                case .success:
                    viewModel.fetchCollections(searchText: searchText, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
                case .failure(let error):
                    networkError = error
                    showingDeleteSongNetworkError.toggle()
                }
            default: break
            }
        }
        .onChange(of: searchText, perform: { searchText in
            viewModel.fetchCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
        })
        .onChange(of: tagSelectionModel.selectedTags, perform: { selectedTags in
            viewModel.fetchCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
        })
        .onChange(of: showDeletedCollections, perform: { showDeletedCollections in
            viewModel.fetchCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
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
            var collection = collection
            collection.deleteDate = nil
            if uploadSecret == nil {
                collection.rootDeleteDate = nil
            }
            SubmitEntitiesUseCase<ClusterCodable>(endpoint: .clusters, requestMethod: .put, uploadObjects: [collection], result: $requestProgress).submit()
        } label: {
            Text(AppText.Actions.restore)
        }
        .tint(Color(uiColor: .green1))
    }
    
    private func deleteLocalMusic() {
        if let selectedCollectionForTrailingActions {
            DeleteLocalMusicUseCase(cluster: selectedCollectionForTrailingActions).delete { result in
                switch result {
                case .success: viewModel.fetchCollections(searchText: searchText, selectedTags: mandatoryTags + tagSelectionModel.selectedTags)
                case .failure(let error):
                    self.deleteLocalMusicError = error
                    showingDeleteLocalMusicAlert.toggle()
                }
            }
        }
    }
    
    private func deleteSong() {
        if let selectedCollectionForTrailingActions {
            DeleteSongUseCase(cluster: selectedCollectionForTrailingActions, progress: $requestProgress).delete()
        }
    }
}

struct CollectionsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsViewUI(editingSection: nil, songServiceEditorModel: nil)
    }
}
