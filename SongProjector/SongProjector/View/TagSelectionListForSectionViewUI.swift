//
//  TagSelectionListForSectionViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 03/07/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import Combine

@MainActor class TagSelectionListForSectionViewModel: ObservableObject {
    
    let songServiceSectionCodable: SongServiceSectionCodable
    private var isLoading = false
    private let fetcher = FetchTagsUseCase()
    @Published var selectionModel: SelectionModel<PinnableTagCodable>
    @Published var error: LocalizedError? = nil
    
    init(songServiceSectionCodable: SongServiceSectionCodable, pinnableTags: [PinnableTagCodable]) {
        self.songServiceSectionCodable = songServiceSectionCodable
        self.selectionModel = SelectionModel(selectedItems: pinnableTags)
    }
    
    func fetchTags() {
        Task {
            self.selectionModel.items = await GetTagsUseCase().fetch().map { PinnableTagCodable(tag: $0) }
        }
    }
    
    func fetchRemoteTags() async {
        fetchTags()
        guard !isLoading else {
            return
        }
        isLoading = true
        do {
            _ = try await FetchTagsUseCase().fetch()
            isLoading = false
            fetchTags()
        } catch {
            self.error = error.forcedLocalizedError
        }
    }

}

struct TagSelectionListForSectionViewUI: View {
    
    @StateObject var viewModel: TagSelectionListForSectionViewModel
    @Binding private var showingTagSelectionListForSectionViewUI: Bool
    private let pinnableTags: PassthroughSubject<[PinnableTagCodable], Never>
    
    init(
        songServiceSectionCodable: SongServiceSectionCodable,
        pinnableTags: [PinnableTagCodable],
        showingTagSelectionListForSectionViewUI: Binding<Bool>,
        pinnableTagsPassThrough: PassthroughSubject<[PinnableTagCodable], Never>
    ) {
        self._viewModel = StateObject(wrappedValue: TagSelectionListForSectionViewModel(songServiceSectionCodable: songServiceSectionCodable, pinnableTags: pinnableTags))
        self._showingTagSelectionListForSectionViewUI = showingTagSelectionListForSectionViewUI
        self.pinnableTags = pinnableTagsPassThrough
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(zip(viewModel.selectionModel.items.indices, viewModel.selectionModel.items)), id: \.0) { index, tag in
                    Button {
                        viewModel.selectionModel.didSelect(tag)
                    } label: {
                        HStack(spacing: 8) {
                            Capsule().fill(viewModel.selectionModel.selectedItems.contains(where: { $0.id == tag.id }) ? Color(uiColor: .softBlueGrey) : .clear)
                                .frame(minWidth: 5, idealWidth: 5, maxWidth: 5, minHeight: 0, maxHeight: .infinity)
                            Text(tag.title ?? "")
                                .styleAs(font: .normal)
                        }
                    }
                }
            }
            .errorAlert(error: $viewModel.error)
            .navigationTitle("Select tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showingTagSelectionListForSectionViewUI = false
                    } label: {
                        Text(AppText.Actions.close)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        pinnableTags.send(viewModel.selectionModel.selectedItems)
                        showingTagSelectionListForSectionViewUI = false
                    } label: {
                        Text(AppText.Actions.done)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
            }
            .task {
                await viewModel.fetchRemoteTags()
            }
        }
    }
}
