//
//  CollectionsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

class ManagedCollections: ObservableObject {
    private var searchText: String? = nil
    private var showDeleted = false
    private var selectedTags: [TagCodable] = []
    @Published private(set) var collections: [ClusterCodable] = []
    
    init() {
        reload()
    }
    func load(searchText: String? = nil, showDeleted: Bool = false, selectedTags: [TagCodable] = []) {
        collections = FilteredCollectionsUseCase().getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
        self.searchText = searchText
        self.showDeleted = showDeleted
        self.selectedTags = selectedTags
    }
    
    func reload() {
        collections = FilteredCollectionsUseCase().getCollections(searchText: searchText, showDeleted: showDeleted, selectedTags: selectedTags)
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
    @ObservedObject var managedCollections = ManagedCollections()
    @State var tagSelectionModel = WrappedStruct(withItem: TagSelectionModel(mandatoryTags: []))

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
                    TagSelectionScrollViewUI(model: tagSelectionModel)
                    Button {
                        showDeletedCollections.toggle()
                    } label: {
                        Text(AppText.Tags.deletedClusters)
                    }
                    .styleAsSelectionCapsuleButton(isSelected: showDeletedCollections)
                }
                .padding([.top, .leading, .trailing])
                List {
                    ForEach(managedCollections.collections, id: \.id) { collection in
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
                                managedCollections: managedCollections,
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

            }
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
        .onAppear {
            managedCollections.load(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.item.selectedTags)
        }
        .onChange(of: requestProgress) { newValue in
            switch newValue {
            case .finished(let result):
                switch result {
                case .success:
                    managedCollections.load(searchText: searchText, selectedTags: mandatoryTags + tagSelectionModel.item.selectedTags)
                case .failure(let error):
                    networkError = error
                    showingDeleteSongNetworkError.toggle()
                }
            default: break
            }
        }
        .onChange(of: searchText, perform: { searchText in
            managedCollections.load(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.item.selectedTags)
        })
        .onChange(of: tagSelectionModel.item.selectedTags, perform: { selectedTags in
            managedCollections.load(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.item.selectedTags)
        })
        .onChange(of: showDeletedCollections, perform: { showDeletedCollections in
            managedCollections.load(searchText: searchText, showDeleted: showDeletedCollections, selectedTags: mandatoryTags + tagSelectionModel.item.selectedTags)
        })
//        .onChange(of: soundPlayer.selectedSong, perform: { <#V#> in
//            <#code#>
//        })
        .sheet(item: $showingCollectionEditor, content: { editor in
            switch editor {
            case .new:
                if let model = ClusterEditorModel(cluster: nil) {
                    CollectionEditorViewUI(model: WrappedStruct(withItem: model), showingCollectionEditor: $showingCollectionEditor)
                }
            case .existing(let cluster):
                if let model = ClusterEditorModel(cluster: cluster) {
                    CollectionEditorViewUI(model: WrappedStruct(withItem: model), showingCollectionEditor: $showingCollectionEditor)
                }
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
//            selectedCollectionForTrailingActions = collection
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
                case .success: managedCollections.load(searchText: searchText, selectedTags: mandatoryTags + tagSelectionModel.item.selectedTags)
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
