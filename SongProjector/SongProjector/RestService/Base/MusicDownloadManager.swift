//
//  MusicDownloadManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation


class MusicDownloadManager: TransferManager {
    var id: String {
        return cluster.id
    }
    private let cluster: VCluster
    
    init(cluster: VCluster) {
        self.cluster = cluster
        super.init(singleTransferManagers: cluster.musicDownloadObjects.compactMap({ FileFetcher(downloadObject: $0) }))
    }

}
