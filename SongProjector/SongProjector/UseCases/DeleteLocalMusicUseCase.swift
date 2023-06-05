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
        try await SaveInstrumentsUseCase().save(entities: cluster.hasInstruments, deleteLocalResourcePath: true)
    }
}
