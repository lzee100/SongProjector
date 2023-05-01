//
//  TagsSelectorViewModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct TagsSelectorViewModel {
    
    let title = AppText.Tags.title
    let tags: [TagCodable]
    var selectedTags: [TagCodable] = []
    
    init() {
        let persitedTags: [Tag] = DataFetcher().getEntities(moc: moc)
        tags = persitedTags.compactMap { TagCodable(managedObject: $0, context: moc) }
    }
    
}
