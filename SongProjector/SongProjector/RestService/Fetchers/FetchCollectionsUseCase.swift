//
//  FetchCollectionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor FetchCollectionsUseCase {
    
    private let useCase: FetchUseCaseAsync<ClusterCodable, Cluster>

    init(fetchAll: Bool) {
        useCase = FetchUseCaseAsync<ClusterCodable, Cluster>(endpoint: uploadSecret == nil ? .clusters : .universalclusters, fetchAll: fetchAll)
    }
    
    @discardableResult
    func fetch() async throws -> [ClusterCodable] {
        try await useCase.fetch()
    }
}
