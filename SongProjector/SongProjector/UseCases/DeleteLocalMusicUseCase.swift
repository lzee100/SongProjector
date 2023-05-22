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
    
    init(cluster: ClusterCodable) {
        self.cluster = cluster
    }
    
    func delete() async throws {
        var instruments: [InstrumentCodable] = []
        for instrument in cluster.hasInstruments {
            var changeableInstrument = instrument
            if let resourcePath = changeableInstrument.resourcePath {
                try FileManager.deleteFile(name: resourcePath)
            }
            changeableInstrument.resourcePath = nil
            instruments.append(changeableInstrument)
        }
        
        try await ManagedObjectContextHandler<InstrumentCodable>().save(entities: instruments)
    }
}
