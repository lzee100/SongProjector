//
//  DeleteSongUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct DeleteSongUseCase {
    
    private let cluster: ClusterCodable
    @Binding private var progress: RequesterResult
    
    init(cluster: ClusterCodable, progress: Binding<RequesterResult>) {
        self.cluster = cluster
        self._progress = progress
    }
    
    func delete() {
        SubmitEntitiesUseCase<ClusterCodable>(endpoint: .clusters, requestMethod: .delete, uploadObjects: [cluster], result: $progress).submit()
    }
}
