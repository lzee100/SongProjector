//
//  ThemeFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

let ThemeFetcher = TemeFetcher()

class TemeFetcher: Requester<VTheme> {
    
    override var id: String {
        return "ThemeFetcher"
    }
    override var path: String {
        return "themes"
    }
    
    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
        let theme: Theme? = DataFetcher().getLastUpdated(moc: moc)
        return theme?.updatedAt as Date?
    }
    
    override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VTheme], completion: @escaping ((Requester<VTheme>.AdditionalProcessResult) -> Void)) {
        let downloadObjects = entities.flatMap({ $0.downloadObjects }).unique { (lhs, rhs) -> Bool in
            return lhs.remoteURL == rhs.remoteURL
        }
        let downloadManager = TransferManager(transferObjects: downloadObjects)
        
        _ = downloadManager.$result.sink { result in
            switch result {
            case .failed(error: let error):
                completion(.failed(error: .failedDownloadingMedia(requester: self.id, error: error)))
            case .success, .none:
                entities.forEach({
                    $0.setDownloadValues(downloadObjects)
                })
                completion(.succes(result: entities))
            }
        }
    }
    
    override func fetch() {
        super.fetch()
    }

    
}
