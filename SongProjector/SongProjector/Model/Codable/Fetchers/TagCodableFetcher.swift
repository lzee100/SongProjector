////
////  TagFetcher.swift
////  SongProjector
////
////  Created by Leo van der Zee on 12/12/2022.
////  Copyright © 2022 iozee. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//class TagRequesterInfo: RequesterInfoBase {
//    
//    override var path: String {
//        "tags"
//    }
//    
//    override init() {
//        super.init()
//        let tag: Tag? = DataFetcher().getLastUpdated(moc: moc)
//        lastUpdatedAt = (tag?.updatedAt as Date?)?.intValue
//    }
//}
//
//struct TagCodableFetcher: CodableFetcherType {
//    
//    func prepareForSubmit(completion: ((Result<[EntityCodableType], Error>) -> Void)) {
//        completion(.success([]))
//    }
//    
//    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
//        let fetcherInfo = TagRequesterInfo()
//
//        FetchUseCase<TagCodable>().fetch(fetcherInfo: fetcherInfo) { result in
//            switch result {
//            case .success(let snapshots):
//                let decodedEntities: [TagCodable] = (try? snapshots.flatMap { try $0.decoded() }) ?? []
//                completion(.success(decodedEntities))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: (Result<[NSManagedObject], Error>) -> Void) {
//        completion(.success(managedObjects))
//    }
//    
//    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType] {
//        objects.compactMap { TagCodable(managedObject: $0, context: context) }
//    }
//    
//}
//
