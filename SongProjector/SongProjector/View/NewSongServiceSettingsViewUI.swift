//
//  NewSongServiceSettingsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import FirebaseAuth

class SongServiceSettingsSection: ObservableObject {

    public let id = UUID().uuidString
    let songServiceSection: SongServiceSectionCodable?
    @Published var title = ""
    @Published var numberOfSongs: Int = 1
    @Published var tags: [WrappedStruct<TagCodable>] = []

    var isValid: Bool {
        return !title.isBlanc && tags.count > 0 && numberOfSongs > 0
    }

    init(songServiceSection: SongServiceSectionCodable? = nil) {
        self.songServiceSection = songServiceSection ?? SongServiceSectionCodable(position: 0, numberOfSongs: 0, tags: [])
        title = songServiceSection?.title ?? ""
        tags = songServiceSection?.tags.map { WrappedStruct(withItem: $0) } ?? []
        numberOfSongs = songServiceSection?.numberOfSongs.intValue ?? 1
    }

}
