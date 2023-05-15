//
//  TagSelectionScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TagSelectionModel {
    let mandatoryTags: [TagCodable]
    private(set) var tags: [TagCodable] = []
    private(set) var selectedTags: [TagCodable]
    private(set) var error: Error? = nil
    private let fetchTagsUseCase: FetchUseCaseCallBack<TagCodable>
    
    init(mandatoryTags: [TagCodable]) {
        self.mandatoryTags = mandatoryTags
        self.selectedTags = mandatoryTags
        fetchTagsUseCase = FetchUseCaseCallBack<TagCodable>(endpoint: .tags)
        
        defer {
            loadPersitedData()
        }
    }
    
    mutating func didSelectTag(_ tag: TagCodable) {
        if selectedTags.contains(where: { $0.id == tag.id }) {
            selectedTags.removeAll(where: { $0.id == tag.id })
        } else {
            selectedTags.append(tag)
        }
    }
        
    mutating func loadPersitedData() {
        let persitedThemes: [Tag] = DataFetcher().getEntities(moc: moc, sort: NSSortDescriptor(key: "position", ascending: true))
        tags = persitedThemes.compactMap { TagCodable(managedObject: $0, context: moc) }
    }
    
}

struct TagSelectionScrollViewUI: View {
    
    @ObservedObject var model: WrappedStruct<TagSelectionModel>
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    ForEach(model.item.tags) { tag in
                        Button {
                            model.item.didSelectTag(tag)
                        } label: {
                            Text(tag.title ?? "-")
                        }
                        .styleAsSelectionCapsuleButton(isSelected: model.item.selectedTags.contains(where: { $0.id == tag.id }))
                        .allowsHitTesting(model.item.mandatoryTags.count == 0)
                        .id(tag.id)
                    }
                }
            }
            .onAppear {
                FetchUseCaseCallBack<TagCodable>(endpoint: .tags).fetch{ progress in
                    switch progress {
                    case .finished(let result):
                        switch result {
                        case .success:
                            model.item.loadPersitedData()
                        case .failure(let error):
                            print(error)
                        }
                    default: break
                    }
                }
                if let mandatoryTagId = model.item.mandatoryTags.first?.id {
                    reader.scrollTo(mandatoryTagId, anchor: .center)
                }
            }
        }
    }
}

struct TagSelectionScrollViewUI_Previews: PreviewProvider {
    @State static var progress: RequesterResult = .idle
    @State static var model = WrappedStruct(withItem: TagSelectionModel(mandatoryTags: []))
    static var previews: some View {
        TagSelectionScrollViewUI(model: model)
    }
}
