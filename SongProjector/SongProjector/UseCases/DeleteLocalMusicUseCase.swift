//
//  DeleteLocalMusicUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation


struct DeleteLocalMusicUseCase {
    
    private let cluster: ClusterCodable
    
    init(cluster: ClusterCodable) {
        self.cluster = cluster
    }
    
    func delete(completion: ((Result<ClusterCodable, Error>) -> Void)) {
        var instruments: [InstrumentCodable] = []
        var hasDeleteError = false
        for instrument in cluster.hasInstruments {
            if !hasDeleteError {
                var changeableInstrument = instrument
                if let resourcePath = changeableInstrument.resourcePath {
                    do {
                        try FileManager.deleteFile(name: resourcePath)
                    } catch {
                        hasDeleteError = true
                        completion(.failure(error))
                    }
                }
                changeableInstrument.resourcePath = nil
                instruments.append(changeableInstrument)
            }
        }
        
        guard !hasDeleteError else { return }
        ManagedObjectContextHandler<InstrumentCodable>().save(entities: instruments) { result in
            switch result {
            case .success:
                completion(.success(self.cluster))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
