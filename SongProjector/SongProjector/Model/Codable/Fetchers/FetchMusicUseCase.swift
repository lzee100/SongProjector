//
//  FetchMusicUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

actor FetchMusicUseCase: ObservableObject {
    
    nonisolated let id: String
    
    private let cluster: ClusterCodable
    private let managedObjectContextHandler = ManagedObjectContextHandler<ClusterCodable>()
    
    init(cluster: ClusterCodable) {
        self.id = cluster.id
        self.cluster = cluster
    }
    
    func fetch() async throws {
        let downloadableFiles = self.cluster.hasInstruments
            .filter({ $0.resourcePath == nil })
            .compactMap { URL(string: $0.resourcePathAWS) }
            .compactMap { DownloadObject(remoteURL: $0) }
        
        var changeableCluster = cluster
        changeableCluster = try await FileDownloadUseCase().startDownloadingFor(cluster)
        
        try await managedObjectContextHandler.save(entities: [changeableCluster])
    }
}
