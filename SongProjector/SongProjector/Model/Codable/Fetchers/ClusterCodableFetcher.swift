////
////  ClusterFetcher.swift
////  SongProjector
////
////  Created by Leo van der Zee on 12/12/2022.
////  Copyright © 2022 iozee. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//fileprivate class ClusterFetcherInfo: RequesterInfoBase {
//
//    override var path: String {
//        "clusters"
//    }
//
//    override init() {
//        super.init()
////        let cluster: Cluster? = DataFetcher().getLastUpdated(moc: moc)
////        lastUpdatedAt = (cluster?.updatedAt as Date?)?.intValue
//    }
//
//}
//
//struct ClusterCodableFetcher: CodableFetcherType {
//
//    func prepareForSubmit(completion: ((Result<[EntityCodableType], Error>) -> Void)) {
//        completion(.success([]))
//    }
//
//    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
//
//        let fetcherProperties = ClusterFetcherInfo()
//
//        FetchUseCase<ClusterCodable>().fetch(fetcherInfo: fetcherProperties) { result in
//            switch result {
//            case .success(let snapshots):
//                let decodedEntities: [ClusterCodable] = (try? snapshots.flatMap { try $0.decoded() }) ?? []
//                completion(.success(decodedEntities))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//
//    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: @escaping (Result<[NSManagedObject], Error>) -> Void) {
//
//            completion(.success(managedObjects))
////            return
////        }
////        let downloadObjects = clustersCodable.flatMap({ $0.downloadObjects }).unique { (lhs, rhs) -> Bool in
////            return lhs.remoteURL == rhs.remoteURL
////        }
////        let downloadManager = TransferManager(transferObjects: downloadObjects)
////
////        _ = downloadManager.$result.sink { result in
////            switch result {
////            case .failed(error: let error): completion(.failure(error))
////            case .success, .none:
////                guard let clusters = managedObjects as? [Cluster] else {
////                    completion(.success(managedObjects))
////                    return
////                }
////                clusters.forEach({
////                    $0.setDownloadValues(downloadObjects, context: context)
////                })
////                completion(.success(clusters))
////            }
////        }
//    }
//
//    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType] {
//        objects.compactMap { ClusterCodable(managedObject: $0, context: context) }
//    }
//
//}
