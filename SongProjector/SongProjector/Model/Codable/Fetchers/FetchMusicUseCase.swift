//
//  FetchMusicUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor class FetchMusicUseCase: ObservableObject {
    
    nonisolated let id: String
    
    private let collection: ClusterCodable
    
    init(collection: ClusterCodable) {
        self.id = collection.id
        self.collection = collection
    }
    
    func fetch() async throws {
        let downloadableFiles = self.collection.hasInstruments
            .filter({ $0.resourcePath == nil })
            .compactMap { URL(string: $0.resourcePathAWS) }
            .compactMap { DownloadObject(remoteURL: $0) }
        
        let updatedCollection = try await FileDownloadUseCase().startDownloadingFor(collection, downloadObjects: downloadableFiles)
//        await delayText()
//        var coll = collection
//        var updatedInstruments: [InstrumentCodable] = []
//        coll.hasInstruments.forEach { instrument in
//            var instru = instrument
//            instru.resourcePath = "asdfsdf"
//            updatedInstruments.append(instru)
//        }
//        coll.hasInstruments = updatedInstruments
        
        try await SaveCodableToCorDataUseCase().save(entities: [updatedCollection])
    }
    
//    private func delayText() async {
//        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
//        try? await Task.sleep(nanoseconds: 1_500_000_000)
//    }

}
