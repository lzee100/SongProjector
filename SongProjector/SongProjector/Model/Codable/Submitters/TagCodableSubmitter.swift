//
//  TagCodableSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import CoreData

struct TagCodableSubmitter: CodableFetcherType {
    
    private let requestMethod: RequestMethod
    private let body: [TagCodable]
    
    init(requestMethod: RequestMethod, body: [TagCodable]) {
        self.requestMethod = requestMethod
        self.body = body
    }
    
    func prepareForSubmit(completion: ((Result<[EntityCodableType], Error>) -> Void)) {
        completion(.success(body))
    }
    
    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
        let fetcherInfo = TagRequesterInfo()

        var submitter = SubmitCodablePerformer<TagCodable>(body: [], requestMethod: requestMethod, requesterInfo: TagRequesterInfo())
        
        submitter.performSubmit { result in
            switch result {
            case .success(let result): completion(.success(result))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: @escaping (Result<[NSManagedObject], Error>) -> Void) {
        completion(.success(managedObjects))
    }
    
    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType] {
        objects.compactMap { TagCodable(managedObject: $0, context: context) }
    }
}
