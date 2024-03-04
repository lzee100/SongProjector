//
//  TagSelectionScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class TagSelectionModel: ObservableObject {
    
    let label = AppText.Tags.title
    let mandatoryTagIds: [String]
    @Published private(set) var tags: [TagCodable] = []
    @Published private(set) var selectedTags: [TagCodable]
    @Published var error: LocalizedError? = nil
    private var isLoading = false
    private var fetchRemoteTags: Bool
    private let addDeleteTag: Bool
    
    init(mandatoryTagIds: [String], selectedTags: [TagCodable] = [], fetchRemoteTags: Bool = true, addDeleteTag: Bool = false) {
        self.mandatoryTagIds = mandatoryTagIds
        self.selectedTags = selectedTags.sorted(by: { $0.position < $1.position})
        self.fetchRemoteTags = fetchRemoteTags
        self.addDeleteTag = addDeleteTag
        defer {
            fetchTags()
        }
    }
    
    func didSelectTag(_ tag: TagCodable) {
        if selectedTags.contains(where: { $0.id == tag.id }) {
            selectedTags.removeAll(where: { $0.id == tag.id })
        } else {
            selectedTags.append(tag)
        }
    }
    
    func fetchTags() {
        Task {
            tags = await GetTagsUseCase().fetch()
            addMandatoryTagsToSelectedTags()
            addDeleteTagIfNeeded()
        }
    }
    
    func fetchRemoteTags() async {
        fetchTags()
        guard fetchRemoteTags else {
            return
        }
        isLoading = true
        do {
            tags = try await FetchTagsUseCase().fetch()
            isLoading = false
            fetchTags()
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }

    private func addMandatoryTagsToSelectedTags() {
        let selTags = selectedTags
        selectedTags = (tags.filter({ mandatoryTagIds.contains($0.id) }) + selTags ).unique.sorted(by: { $0.position < $1.position })
    }

    private func addDeleteTagIfNeeded() {
        if addDeleteTag {
            let deleteTag = TagCodable(title: AppText.Tags.deletedClusters, isDeletable: false)
            tags.append(deleteTag)
        }
    }
}

struct TagSelectionScrollViewUI: View {
    
    @StateObject var viewModel: TagSelectionModel
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    ForEach(viewModel.tags) { tag in
                        Button {
                            viewModel.didSelectTag(tag)
                        } label: {
                            Text(tag.title ?? "-")
                        }
                        .styleAsSelectionCapsuleButton(isSelected: viewModel.selectedTags.contains(where: { $0.id == tag.id }))
                        .allowsHitTesting(viewModel.mandatoryTagIds.count == 0)
                        .id(tag.id)
                    }
                }
            }
            .onChange(of: viewModel.tags, { _, _ in
                if let mandatoryTagId = viewModel.mandatoryTagIds.first {
                    reader.scrollTo(mandatoryTagId)
                }
                else if let selectedTagId = viewModel.selectedTags.first?.id {
                    reader.scrollTo(selectedTagId)
                }
            })
            .errorAlert(error: $viewModel.error)
        }
    }
}

struct TagSelectionScrollViewUI_Previews: PreviewProvider {
    @State static var model = TagSelectionModel(mandatoryTagIds: [])
    static var previews: some View {
        TagSelectionScrollViewUI(viewModel: model)
    }
}
