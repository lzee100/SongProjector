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
    private let fetchTagsUseCase: FetchUseCaseCallBack<TagCodable>
    private var isLoading = false
    private var fetchRemoteTags: Bool

    init(mandatoryTags: [TagCodable], selectedTags: [TagCodable] = [], fetchRemoteTags: Bool = true) {
        self.mandatoryTags = mandatoryTags
        self.selectedTags = (mandatoryTags + selectedTags).unique.sorted(by: { $0.position < $1.position})
        self.fetchRemoteTags = fetchRemoteTags
        fetchTagsUseCase = FetchUseCaseCallBack<TagCodable>(endpoint: .tags)
        
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
        do {
            let result = try await FetchTagsUseCase.fetch()
            switch result {
            case .failed(let error): self.error = error
            case .succes(let tags): saveLocally(tags)
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    private func saveLocally(_ entities: [TagCodable]) {
        ManagedObjectContextHandler<TagCodable>().save(entities: entities, completion: { [weak self] _ in
            self?.fetchTags()
            self?.isLoading = false
        })
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
            }
            .errorAlert(error: $viewModel.error)
            .onAppear {
                FetchUseCaseCallBack<TagCodable>(endpoint: .tags).fetch{ progress in
                    switch progress {
                    case .finished(let result):
                        switch result {
                        case .success:
                            viewModel.fetchTags()
                        case .failure(let error):
                            print(error)
                        }
                    default: break
                    }
                }
                if let mandatoryTagId = viewModel.mandatoryTags.first?.id {
                    reader.scrollTo(mandatoryTagId)
                }
                else if let selectedTagId = viewModel.selectedTags.first?.id {
                    reader.scrollTo(selectedTagId)
                }
            }
        }
    }
}

struct TagSelectionScrollViewUI_Previews: PreviewProvider {
    @State static var progress: RequesterResult = .idle
    @State static var model = TagSelectionModel(mandatoryTags: [])
    static var previews: some View {
        TagSelectionScrollViewUI(viewModel: model)
    }
}
