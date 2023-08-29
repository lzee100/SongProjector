//
//  FetchCollectionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor FetchCollectionsUseCase {
    
    private let fetchAll: Bool
    
    init(fetchAll: Bool) {
        self.fetchAll = fetchAll
    }
    
    @discardableResult
    func fetch() async throws -> [ClusterCodable] {
        let endpoint = await GetCollectionsEndpointUseCase().get()
        let useCase = FetchUseCaseAsync<ClusterCodable, Cluster>(endpoint: endpoint, fetchAll: fetchAll)

        return try await useCase.fetch()
    }
}
