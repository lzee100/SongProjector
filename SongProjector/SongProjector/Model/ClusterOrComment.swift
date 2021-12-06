//
//  ClusterOrComment.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/09/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

class ClusterOrComment {
    let id: String?
    var cluster: VCluster?
    var isSelected = false
    
    init(cluster: VCluster?) {
        self.id = cluster?.id
        self.cluster = cluster
    }
    
    func refresh() {
        if let id = self.id, let cluster: Cluster = DataFetcher().getEntity(moc: moc, predicates: [.get(id: id)]) {
            moc.refresh(cluster, mergeChanges: false)
            self.cluster = VCluster(cluster: cluster, context: moc)
        }
    }
}
