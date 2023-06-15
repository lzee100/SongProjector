//
//  FetchUniversalCollectionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor FetchUniversalCollectionsUseCase {
    
    private(set) var isFetching = false
    
    func fetch() async throws -> [ClusterCodable] {
        guard !isFetching else { return [] }
        let date = await GetUniversalUpdatedAtDateUseCase().get()?.universalUpdatedAt
        return try await FetchUseCaseAsyncTask<ClusterCodable>(endpoint: .universalclusters, fetchAll: false, saveData: false).fetch(snapshots: [], lastUpdatedAt: date)
    }
    
}
