//
//  CollectionsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class MusicDownloadManager: ObservableObject {
    
    @Published private var musicDownloaders: [FetchMusicUseCase] = []
    
    func downloadMusicFor(collection: WrappedStruct<ClusterCodable>) async throws {
        guard !musicDownloaders.contains(where: { $0.id == collection.item.id }) else { return }
        let fetchMusicUseCase = FetchMusicUseCase(collection: collection)
        musicDownloaders.append(fetchMusicUseCase)
        try await fetchMusicUseCase.fetch()
        musicDownloaders.removeAll(where: { $0.id == collection.item.id })
    }

    func isDownloading(for collection: WrappedStruct<ClusterCodable>) async -> Bool {
        musicDownloaders.contains(where: { $0.id == collection.item.id })
    }

}

@MainActor class CollectionsViewModel: ObservableObject {
    
    @Published var error: LocalizedError?
    
    @Published private(set) var collections: [ClusterCodable] = []
    @Published private(set) var showingLoader = false
    
    private var searchText: String? = nil
    private var showDeleted = false
    private var selectedTags: [TagCodable] = []
    
    func fetchCollections(searchText: String? = nil, showDeleted: Bool = false, selectedTags: [TagCodable] = []) async {
        collections = await FilteredCollectionsUseCase.getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
        self.searchText = searchText
        self.showDeleted = showDeleted
        self.selectedTags = selectedTags
    }
    
    func reload() async {
        let searchText = self.searchText?.isBlanc ?? true ? nil : self.searchText
        collections = await FilteredCollectionsUseCase.getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
    }
    
    func fetchRemoteThemes() async {
        guard !showingLoader else { return }
        
        showingLoader = true
        
        await reload()
        do {
            let newThemes = try await FetchThemesUseCase(fetchAll: false).fetch()
            if newThemes.count > 0 {
                showingLoader = false
                await fetchRemoteThemes()
            } else {
                self.showingLoader = false
            }
        } catch {
            self.showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func fetchRemoteCollections() async {
        guard !showingLoader else { return }
        showingLoader = true
        print("fetching remote collections")
        do {
            let newCollections = try await FetchCollectionsUseCase(fetchAll: false).fetch()
            if newCollections.count > 0 {
                showingLoader = false
                await fetchRemoteCollections()
            } else {
                await reload()
                print("done")
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
        if uploadSecret == nil {
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
}

struct CollectionsViewUI: View {
    
    enum AlertMessage {
        case delete(ClusterCodable)
        case deleteMusic(ClusterCodable)
    }
    
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
    @ObservedObject var songServiceEditorModel: SongServiceEditorModel
    @State var showingCollectionsViewUI: Binding<Bool>? = nil
    @State var mandatoryTags: [TagCodable] = []
    @StateObject var viewModel = CollectionsViewModel()
    @StateObject var tagSelectionModel = TagSelectionModel(mandatoryTags: [])

    @State private var showingError = false
    @State private var selectedCollectionForTrailingActions: ClusterCodable?
    @State private var showingCollectionEditor: CollectionEditor?
    @State private var showDeletedCollections = false
    @State private var searchText = ""
    @State private var alertMessage: AlertMessage? = nil
    @SwiftUI.Environment(\.colorScheme) var colorScheme

    private var allowsRowSelection: Bool {
        if songServiceEditorModel.sectionedSongs.count == 0 || songServiceEditorModel.customSelectedSongs.count == 0 {
            return editingSection == nil
        } else {
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
            
                ProgressView()
                    .padding([.leading, .trailing])
                    .tint(Color(uiColor: .blackColor).opacity(0.8))
                    .transition(.scale)
                    .opacity(viewModel.showingLoader ? 1 : 0)

                List {
                    ForEach(viewModel.collections, id: \.id) { collection in
                        Button {
                            if let editingSection {
                                songServiceEditorModel.add(collection, to: editingSection)
                            } else if songServiceEditorModel.isInUsage {
                                songServiceEditorModel.didSelect(collection)
                            } else {
                                showingCollectionEditor = .existing(collection)
                            }
                        } label: {
                            CollectionListViewUI(
                                collectionsViewModel: viewModel,
                                collection: collection,
                                isSelectable: songServiceEditorModel.isInUsage,
                                isSelected: songServiceEditorModel.isInUsage ? songServiceEditorModel.isSelected(collection) : false
                            )
                            .frame(minHeight: 50)
                        }
                        .buttonStyle(.borderless)
                        .tint(.black.opacity(0.8))
                        .swipeActions {
                            if showDeletedCollections {
                                restore(collection: collection)
                            } else {
                                deleteSongButton(collection: collection)
                                if collection.hasLocalMusic {
                                    deleteLMusicButton(collection: collection)
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
            .background(Color(uiColor: colorScheme == .dark ? .black : .systemGray6))
            .searchable(text: $searchText).tint(Color(uiColor: themeHighlighted))
        }
        .task {
            await viewModel.fetchRemoteThemes()
            await viewModel.fetchRemoteCollections()
        }
        .onChange(of: searchText, perform: { searchText in
            Task {
                await viewModel.fetchCollections(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: (mandatoryTags + tagSelectionModel.selectedTags).unique)
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
        .alert(isPresented: $showingError, content: {
            switch alertMessage {
            case .delete(let cluster):
                return Alert(title: Text(AppText.Songs.deleteBody(songName: cluster.title ?? "")), message: nil, primaryButton: Alert.Button.destructive(Text(AppText.Actions.delete), action: {
                    Task {
                        await viewModel.delete(cluster)
                    }
                }), secondaryButton: Alert.Button.cancel({
                    alertMessage = nil
                }))
            case .deleteMusic(let cluster):
                return Alert(title: Text(AppText.Songs.deleteMusicBody(songName: cluster.title ?? "")), message: nil, primaryButton: Alert.Button.destructive(Text(AppText.Actions.delete), action: {
                    Task {
                        await viewModel.deleteMusicFor(cluster)
                    }
                }), secondaryButton: Alert.Button.cancel({
                    alertMessage = nil
                }))
            case .none:
                return Alert(title: Text(""), message: nil, dismissButton: .cancel())
            }
        })
        .sheet(item: $showingCollectionEditor, onDismiss: {
            Task {
                await viewModel.reload()
            }
        }, content: { editor in
            switch editor {
            case .new:
                CollectionEditorViewUI(cluster: nil, showingCollectionEditor: $showingCollectionEditor)
            case .existing(let cluster):
                CollectionEditorViewUI(cluster: cluster, showingCollectionEditor: $showingCollectionEditor)
            }
        })
    }
    
    @ViewBuilder private func deleteLMusicButton(collection: ClusterCodable) -> some View {
        Button {
            alertMessage = .deleteMusic(collection)
            showingError = true
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
            showingError = true
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
}

struct CollectionsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsViewUI(editingSection: nil, songServiceEditorModel: SongServiceEditorModel())
    }
}
