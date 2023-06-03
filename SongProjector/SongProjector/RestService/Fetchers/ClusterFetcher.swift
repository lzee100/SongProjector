//
//  ClusterFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let ClusterFetcher = CsterFetcher()

class CsterFetcher: Requester<VCluster> {
    
    override var id: String {
        return "ClusterFetcher"
    }
    
    override var dependencies: [RequesterBase] {
        return [TagFetcher, ThemeFetcher]
    }
    
    override var path: String {
        if uploadSecret != nil {
            return "universalclusters"
        } else {
            return "clusters"
        }
    }
    
//    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
//        let cluster: Cluster? = DataFetcher().getLastUpdated(moc: moc)
//        return cluster?.updatedAt as Date?
//    }
    
    override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VCluster], completion: @escaping ((Requester<VCluster>.AdditionalProcessResult) -> Void)) {
        
        let downloadObjects = entities.flatMap({ $0.downloadObjects }).unique { (lhs, rhs) -> Bool in
            return lhs.remoteURL == rhs.remoteURL
        }
        let downloadManager = TransferManager(transferObjects: downloadObjects)
        
        downloadManager.start()
        
        _ = downloadManager.$result.sink { result in
            switch result {
            case .failed(error: let error): completion(.failed(error: .failedDownloadingMedia(requester: self.id, error: error)))
            case .success, .none:
                entities.forEach({
                    $0.setDownloadValues(downloadObjects)
                })
                completion(.succes(result: entities))
            }
        }
    }
        
}
