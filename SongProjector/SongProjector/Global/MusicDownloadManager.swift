//
//  MusicDownloadManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/03/2024.
//  Copyright © 2024 iozee. All rights reserved.
//

import Observation

@Observable class MusicDownloadManager {

    private(set) var musicDownloaders: [FetchMusicUseCase] = []

    func downloadMusicFor(collection: ClusterCodable) async throws {
        guard !musicDownloaders.contains(where: { $0.id == collection.id }) else { return }
        let fetchMusicUseCase = await FetchMusicUseCase(collection: collection)
        musicDownloaders.append(fetchMusicUseCase)
        try await fetchMusicUseCase.fetch()
        musicDownloaders.removeAll(where: { $0.id == collection.id })
    }

    func isDownloading(for collection: ClusterCodable) -> Bool {
        musicDownloaders.contains(where: { $0.id == collection.id })
    }

}
