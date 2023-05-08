////
////  ThemeFetcher.swift
////  SongProjector
////
////  Created by Leo van der Zee on 12/12/2022.
////  Copyright © 2022 iozee. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//class ThemeRequesterInfo: RequesterInfoBase {
//    
//    override var path: String {
//        "themes"
//    }
//        
//    override init() {
//        super.init()
////        let theme: Theme? = DataFetcher().getLastUpdated(moc: moc)
////        lastUpdatedAt = (theme?.updatedAt as Date?)?.intValue
//    }
//    
//}
//
//struct ThemeCodableFetcher: CodableFetcherType {
//    
//    func prepareForSubmit(completion: ((Result<[EntityCodableType], Error>) -> Void)) {
//        completion(.success([]))
//    }
//    
//    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
//        let fetcherProperties = ThemeRequesterInfo()
//        
//        FetchUseCase<ThemeCodable>().fetch(fetcherInfo: fetcherProperties) { result in
//            switch result {
//            case .success(let snapshots):
//                let decodedEntities: [ThemeCodable] = (try? snapshots.flatMap { try $0.decoded() }) ?? []
//                completion(.success(decodedEntities))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: @escaping (Result<[NSManagedObject], Error>) -> Void) {
//        completion(.success(managedObjects))
//    }
//    
//    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType] {
//        objects.compactMap { ClusterCodable(managedObject: $0, context: context) }
//    }
//    
//}
