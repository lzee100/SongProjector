//
//  TagSelectionViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TagSelectionViewUI: View {
    
    @ObservedObject private var model: WrappedStruct<TagsSelectionModel>
    
    init(model: WrappedStruct<TagsSelectionModel>) {
        self.model = model
    }
    
    var body: some View {
        DisclosureGroup() {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    ForEach(model.item.tags) { tag in
                        Button {
                            model.item.didSelectTag(tag)
                        } label: {
                            Text(tag.title ?? "-")
                        }
                        .styleAsSelectionCapsuleButton(isSelected: model.item.selectedTags.contains(where: { $0.id == tag.id }))
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        } label: {
            HStack() {
                Text(model.item.label)
                    .styleAs(font: .xNormal)
                Spacer()
            }
        }
    }
}

struct TagSelectionViewUI_Previews: PreviewProvider {
    
    @State static var selectedTags: [TagCodable] = []
    @State static var model = WrappedStruct(withItem: TagsSelectionModel(label: AppText.Tags.title, selectedTags: selectedTags, didSelectTags: {_ in }))
    
    static var previews: some View {
        TagSelectionViewUI(model: model)
    }
    
}
