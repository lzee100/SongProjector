//
//  SubmitCodablePerformer.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import CoreData
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

struct SubmitCodablePerformer<T: EntityCodableType> {
    
    private let requesterInfo: RequesterInfo
    private let body: [T]
    private let requestMethod: RequestMethod
    private let db = Firestore.firestore()

    init(body: [T], requestMethod: RequestMethod, requesterInfo: RequesterInfo) {
        self.body = body
        self.requestMethod = requestMethod
        self.requesterInfo = requesterInfo
    }
    
    func performSubmit(completion: @escaping ((Result<[T], Error>) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var workload = body
            var submittedDocuments: [T] = []
            
            func submitDocument(document: T) {
                
                do {
                    
                    var modifiedDocument = try updateDocumentDeleteDateUpdatedAtDate(document)
                    
                    let data = try JSONEncoder().encode(document)
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                        completion(.failure(CodableError.encoding))
                        return
                    }
                    
                    self.db.collection(self.requesterInfo.path).document(document.id).setData(json) { (error) in
                        if let error = error {
                            Queues.main.async {
                                completion(.failure(CodableError.submitting(error: error)))
                            }
                        } else {
                            modifiedDocument.id = self.db.collection(self.requesterInfo.path).document(document.id).documentID
                            submittedDocuments.append(modifiedDocument)
                            workload.removeFirst()
                            if let document = workload.first {
                                submitDocument(document: document)
                            } else {
                                do {
                                    try save(submittedDocuments) { savedDecodables in
                                        Queues.main.async {
                                            completion(.success(savedDecodables))
                                        }
                                    }
                                } catch {
                                    Queues.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                        }
                    }
                    
                } catch {
                    Queues.main.async {
                        completion(.failure(CodableError.encodingJson(error: error)))
                    }
                    return
                }
            }
            if let document = workload.first {
                submitDocument(document: document)
            } else {
                completion(.success([]))
            }
        }
    }
    
    private func save(_ data: [T], completion: (([T]) -> Void)) throws {
        let managedContext = newMOCBackground
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        try managedContext.performAndWait {
            let managedObjects: [NSManagedObject] = data.map { $0.getManagedObjectFrom(managedContext) }
            try managedContext.save()
            try moc.save()
            completion(managedObjects.compactMap { T.init(managedObject: $0, context: managedContext) })
        }
    }
    
    private func updateDocumentDeleteDateUpdatedAtDate(_ document: T) throws -> T {
        var modifiedDocument = document
        if case .delete = self.requestMethod {
            if uploadSecret != nil {
                modifiedDocument.rootDeleteDate = Date()
            } else {
                modifiedDocument.deleteDate = Date()
            }
        }
        modifiedDocument.updatedAt = Date()

        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        modifiedDocument.userUID = userUID

        return modifiedDocument
    }
}
