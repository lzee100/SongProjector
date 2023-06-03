//
//  DeleteLocalMusicUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation


actor DeleteLocalMusicUseCase {
    
    private let cluster: ClusterCodable
    private let context = newMOCBackground
    
    init(cluster: ClusterCodable) {
        self.cluster = cluster
    }
    
    func delete() async throws {
        let deleteObjects = cluster.hasInstruments.flatMap { $0.getDeleteObjects(forceDelete: true) }
        try await SubmitUseCase(endpoint: .clusters, requestMethod: .put, uploadObjects: [cluster], deleteObjects: deleteObjects).submit()
    }
}
