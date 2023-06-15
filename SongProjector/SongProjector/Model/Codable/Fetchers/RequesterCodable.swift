//
//  RequesterCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import CoreData
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

enum CodableError: Error {
    case noInternet
    case encodingJson(error: Error)
    case encoding
    case submitting(error: Error)
    
    case savingTempImage(error: Error)
    case savingImage(error: Error)
    case uploadingImage(error: Error)
    case noFireBaseUser
}


protocol CodableFetcherType {
    func prepareForSubmit(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void))
    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void))
    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: @escaping (Result<[NSManagedObject], Error>) -> Void)
    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType]
}

protocol RequesterInfo {
    var path: String { get }
    var lastUpdatedAt: Int64? { get }
    func setLastUpdatedAt(_ objects: [EntityCodableType])
}

class RequesterCodable {
    
    private let requests: [CodableFetcherType]
    private let completion: (Result<[EntityCodableType], Error>) -> Void
    private let managedContext: NSManagedObjectContext
    
    private var requestResults: [(requester: CodableFetcherType, decodedEntities: [EntityCodableType])] = []
    
    init(requests: [CodableFetcherType], completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
        self.requests = requests
        self.completion = completion
        self.managedContext = newMOCBackground
    }
    
    func startRequest() {
        perform()
    }
    
    private func perform() {
        guard hasInternet else {
            completion(.failure(CodableError.noInternet))
            return
        }
        
        if let firstRequest = requests.first {
            firstRequest.prepareForSubmit { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_): self.performFor(firstRequest, index: 0)
                case .failure(let error):
                    self.completion(.failure(error))
                }
            }
            performFor(firstRequest, index: 0)
        } else {
            completion(.success([]))
        }
    }
    
    private func performFor(_ request: CodableFetcherType, index: Int) {
        request.perform { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.requestResults.append((request, result))
                if let request = self.requests[safe: index + 1] {
                        request.prepareForSubmit { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(_):
                                self.performFor(request, index: index + 1)
                            case .failure(let error):
                                self.completion(.failure(error))
                            }
                        }
                } else {
                    self.startAdditionalProcessing()
                }
            case .failure(let error):
                self.completion(.failure(error))
            }
        }
    }
    
    private func startAdditionalProcessing() {
        
        guard let firstRequestResult = requestResults.first else {
            completion(.success([]))
            return
        }
        managedContext.performAndWait { [weak self] in
            
            guard let self = self else { return }
            
            var workload = self.requestResults
            var finishedWorkload: [(CodableFetcherType, [NSManagedObject])] = []
//            func handle(requester: CodableFetcherType, decodedEntities: [EntityCodableType]) {
//                let managedObjects: [NSManagedObject] = decodedEntities.map { $0.getManagedObjectFrom(self.managedContext) }
//                requester.additionalProcessing(decodedEntities: decodedEntities, managedObjects: managedObjects, context: managedContext) { result in
//                    switch result {
//                    case .success(let updatedManagedObjects):
//                        workload.removeFirst()
//                        finishedWorkload.append((requester, updatedManagedObjects))
//                        if let requestResult = workload.first {
//                            handle(requester: requestResult.requester, decodedEntities: requestResult.decodedEntities)
//                        } else {
//                            do {
//                                try self.managedContext.save()
//                                try moc.save()
//                                self.completion(.success(self.revertToCodable(workload: finishedWorkload, context: self.managedContext)))
//                            } catch {
//                            }
//                        }
//                    case .failure(let error):
//                    }
//                }
//            }
//            
//            handle(requester: firstRequestResult.requester, decodedEntities: firstRequestResult.decodedEntities)
        }
    }
    
    func revertToCodable(workload: [(CodableFetcherType, [NSManagedObject])], context: NSManagedObjectContext) -> [EntityCodableType] {
        workload.flatMap { (requester, managedObjects) in
            requester.getCodableObjectFrom(managedObjects, context: context)
        }
    }
}

