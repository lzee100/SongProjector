//
//  FetchCollectionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FetchCollectionsUseCase {
    
    private let useCase: FetchUseCaseAsync<ClusterCodable, Cluster>

    init(fetchAll: Bool) {
        useCase = FetchUseCaseAsync<ClusterCodable, Cluster>(endpoint: .clusters, fetchAll: fetchAll)
    }
    
    func fetch() async throws -> FetchUseCaseAsyncTask<ClusterCodable>.FetchUseCaseAsyncDownloadResult {
        try await useCase.fetch()
    }
}

struct FetchThemesUseCase {
    
    private let useCase: FetchUseCaseAsync<ThemeCodable, Theme>

    init(fetchAll: Bool) {
        useCase = FetchUseCaseAsync<ThemeCodable, Theme>(endpoint: .themes, fetchAll: fetchAll)
    }
    
    func fetch() async throws -> FetchUseCaseAsyncTask<ThemeCodable>.FetchUseCaseAsyncDownloadResult {
        try await useCase.fetch()
    }
}
