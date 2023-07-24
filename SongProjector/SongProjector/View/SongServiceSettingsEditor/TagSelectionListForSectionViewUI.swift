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
    
    let editorSectionViewModel: SongServiceEditorSectionViewModel
    private var isLoading = false
    private let fetcher = FetchTagsUseCase()
    @Published var selectionModel: SelectionModel<TagCodable>
    @Published var error: LocalizedError? = nil
    @Binding private var showingTagSelectionListForSectionViewUI: Bool

    init(
        editorSectionViewModel: SongServiceEditorSectionViewModel,
        showingTagSelectionListForSectionViewUI: Binding<Bool>

    ) {
        self.editorSectionViewModel = editorSectionViewModel
        self._showingTagSelectionListForSectionViewUI = showingTagSelectionListForSectionViewUI
        self.selectionModel = SelectionModel(selectedItems: editorSectionViewModel.tags)
    }
    
    func fetchTags() {
        Task {
            self.selectionModel.items = await GetTagsUseCase().fetch()
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
    
    func didPressDone() {
        editorSectionViewModel.didSelect(selectionModel.selectedItems)
        showingTagSelectionListForSectionViewUI = false
    }
    
    func didPressCancel() {
        showingTagSelectionListForSectionViewUI = false
    }

}

struct TagSelectionListForSectionViewUI: View {
    
    @StateObject var viewModel: TagSelectionListForSectionViewModel
    private let songServiceSettingsEditorViewModel: SongServiceSettingsEditorViewModel
    
    init(
        songServiceSettingsEditorViewModel: SongServiceSettingsEditorViewModel,
        editorSectionViewModel: SongServiceEditorSectionViewModel,
        showingTagSelectionListForSectionViewUI: Binding<Bool>
    ) {
        self.songServiceSettingsEditorViewModel = songServiceSettingsEditorViewModel
        self._viewModel = StateObject(wrappedValue: TagSelectionListForSectionViewModel(
            editorSectionViewModel: editorSectionViewModel,
            showingTagSelectionListForSectionViewUI: showingTagSelectionListForSectionViewUI
        ))
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
                        viewModel.didPressCancel()
                    } label: {
                        Text(AppText.Actions.close)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.didPressDone()
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
