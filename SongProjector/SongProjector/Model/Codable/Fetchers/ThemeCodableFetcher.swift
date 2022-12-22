//
//  ThemeFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import CoreData

class ThemeRequesterInfo: RequesterInfoBase {
    
    override var path: String {
        "themes"
    }
        
    override init() {
        super.init()
//        let theme: Theme? = DataFetcher().getLastUpdated(moc: moc)
//        lastUpdatedAt = (theme?.updatedAt as Date?)?.intValue
    }
    
}

struct ThemeCodableFetcher: CodableFetcherType {
    
    func prepareForSubmit(completion: ((Result<[EntityCodableType], Error>) -> Void)) {
        completion(.success([]))
    }
    
    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
        let fetcherProperties = ThemeRequesterInfo()
        
        FetcherPerformer<ThemeCodable>().fetch(fetcherInfo: fetcherProperties) { result in
            switch result {
            case .success(let snapshots):
                let decodedEntities: [ThemeCodable] = (try? snapshots.flatMap { try $0.decoded() }) ?? []
                completion(.success(decodedEntities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: @escaping (Result<[NSManagedObject], Error>) -> Void) {
        
        guard let themeCodable = decodedEntities as? [ThemeCodable] else {
            completion(.success(managedObjects))
            return
        }
        
        let downloadObjects = themeCodable.flatMap({ $0.downloadObjects }).unique { (lhs, rhs) -> Bool in
            return lhs.remoteURL == rhs.remoteURL
        }
        
        let downloadManager = TransferManager(objects: downloadObjects)
        
        downloadManager.start(progress: { (progress) in
        }) { (result) in
            switch result {
            case .failed(error: let error): completion(.failure(error))
            case .success:
                guard let themes = managedObjects as? [Theme] else {
                    completion(.success(managedObjects))
                    return
                }
                themes.forEach { $0.setDownloadValues(downloadObjects) }
                completion(.success(themes))
            }
        }
    }
    
    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType] {
        objects.compactMap { ClusterCodable(managedObject: $0, context: context) }
    }
    
}
