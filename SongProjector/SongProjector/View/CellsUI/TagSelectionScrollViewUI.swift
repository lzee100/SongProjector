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
    let mandatoryTags: [TagCodable]
    @Published private(set) var tags: [TagCodable] = []
    @Published private(set) var selectedTags: [TagCodable]
    @Published var error: LocalizedError? = nil
    private var isLoading = false
    private var fetchRemoteTags: Bool
    
    init(mandatoryTags: [TagCodable], selectedTags: [TagCodable] = [], fetchRemoteTags: Bool = true) {
        self.mandatoryTags = mandatoryTags
        self.selectedTags = (mandatoryTags + selectedTags).unique.sorted(by: { $0.position < $1.position})
        self.fetchRemoteTags = fetchRemoteTags
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
        let persitedThemes: [Tag] = DataFetcher().getEntities(moc: moc, sort: NSSortDescriptor(key: "position", ascending: true))
        tags = persitedThemes.compactMap { TagCodable(managedObject: $0, context: moc) }
    }
    
    func fetchRemoteTags() async {
        guard fetchRemoteTags else {
            fetchTags()
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
                        .allowsHitTesting(viewModel.mandatoryTags.count == 0)
                        .id(tag.id)
                    }
                }
            }
            .task {
                await viewModel.fetchRemoteTags()
                if let mandatoryTagId = viewModel.mandatoryTags.first?.id {
                    reader.scrollTo(mandatoryTagId)
                }
                else if let selectedTagId = viewModel.selectedTags.first?.id {
                    reader.scrollTo(selectedTagId)
                }
            }
            .errorAlert(error: $viewModel.error)
        }
    }
}

struct TagSelectionScrollViewUI_Previews: PreviewProvider {
    @State static var model = TagSelectionModel(mandatoryTags: [])
    static var previews: some View {
        TagSelectionScrollViewUI(viewModel: model)
    }
}
