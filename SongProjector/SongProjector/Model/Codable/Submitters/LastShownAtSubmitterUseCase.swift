//
//  LastShownAtSubmitterUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor LastShownAtSubmitterUseCase {
    
    private let collection: ClusterCodable
    
    init(collection: ClusterCodable) {
        self.collection = collection
    }
    
    func setPlayDate() async {
        var updateableCollection = collection
        updateableCollection.lastShownAt = Date()
        try? await SaveClustersUseCase().save(entities: [updateableCollection])
        _ = try? await SubmitUseCase(endpoint: uploadSecret == nil ? .clusters : .universalclusters, requestMethod: .put, uploadObjects: [updateableCollection]).submit()
    }
    
    
}
