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
    
    private let collection: WrappedStruct<ClusterCodable>
    
    init(collection: WrappedStruct<ClusterCodable>) {
        self.id = collection.item.id
        self.collection = collection
    }
    
    func fetch() async throws {
        let downloadableFiles = self.collection.item.hasInstruments
            .filter({ $0.resourcePath == nil })
            .compactMap { URL(string: $0.resourcePathAWS) }
            .compactMap { DownloadObject(remoteURL: $0) }
        
        collection.item = try await FileDownloadUseCase().startDownloadingFor(collection.item, downloadObjects: downloadableFiles)
        
        try await SaveCodableToCorDataUseCase().save(entities: [collection.item])
    }
}
