//
//  Requester.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/05/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UserNotifications
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import CoreData

enum RequestError: LocalizedError {
    case failedSavingImageLocallyBeforeSubmit(requester: String, error: Error)
    case wrongMethodForSubmitting(requester: String)
    case failedDecoding(requester: String)
    case failedEncoding(requester: String)
    case unAuthorizedNoUser(requester: String)
    case allreadyHasAnUser(requester: String)
    case hasNoThemeForUniversalCluster(requester: String)
    case hasNoChurchForUniversalCluster(requester: String)
    case failedFetchingSavingCoreData(requester: String, error: Error)
    case errorOnFireBase(requester: String, error: Error)
    case failedDownloadingMedia(requester: String, error: Error)
    case failedUploadingMedia(requester: String, error: Error)
    case failedSavingLocalImage(requester: String, error: Error)
    case notConnectedToNetwork
    case unknown(requester: String, error: Error)
    
    var errorDescription: String? {
        switch self {
        case .failedUploadingMedia(requester: let requester, error: let error): return AppText.RequesterErrors.failedUploadingMedia(requester: requester, error: error)
        case .failedSavingImageLocallyBeforeSubmit(requester: let requester, error: let error): return AppText.RequesterErrors.failedSavingImageLocallyBeforeSubmit(requester: requester, error: error)
        case .failedDownloadingMedia(requester: let requester, error: let error): return AppText.RequesterErrors.failedDownloadingMedia(requester: requester, error: error)
        case .wrongMethodForSubmitting(let requester): return AppText.RequesterErrors.wrongMethodForSubmitting(requester: requester)
        case .failedDecoding(let requester): return AppText.RequesterErrors.failedDecoding(requester: requester)
        case .failedEncoding(let requester): return AppText.RequesterErrors.failedEncoding(requester: requester)
        case .unAuthorizedNoUser(let requester): return AppText.RequesterErrors.unAuthorizedNoUser(requester: requester)
        case .allreadyHasAnUser(let requester): return AppText.RequesterErrors.allreadyHasAnUser(requester: requester)
        case .hasNoThemeForUniversalCluster(let requester): return AppText.RequesterErrors.hasNoThemeForUniversalCluster(requester: requester)
        case .hasNoChurchForUniversalCluster(let requester): return AppText.RequesterErrors.hasNoChurchForUniversalCluster(requester: requester)
        case .errorOnFireBase(requester: let requester, let error): return AppText.RequesterErrors.errorOnFireBase(requester: requester, error: error)
        case .failedFetchingSavingCoreData(requester: let requester, error: let error): return AppText.RequesterErrors.failedFetchingSavingCoreData(requester: requester, error: error)
        case .failedSavingLocalImage(requester: let requester, error: let error): return AppText.RequesterErrors.errorSavingTempImage(requester: requester, error: error)
        case .notConnectedToNetwork: return AppText.RequesterErrors.notConnectedToNetwork()
        case .unknown(requester: let requester, error: let error): return AppText.RequesterErrors.unknown(requester: requester, error: error)
        }
    }
}

enum RequestResult {
    case success(Any)
    case failed(RequestError)
    
    var isSuccess: Bool {
        switch self {
        case .success(_):return true
        default: return false
        }
    }
}

protocol RequesterObserver1: AnyObject {
    func requesterDidStart()
    func requesterDidProgress(progress: CGFloat)
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool)
}

extension RequesterObserver1 {
    func requesterDidStart() {}
    func requesterDidProgress(progress: CGFloat) {}
}

class Requester<T>: NSObject, RequesterBase where T: VEntity {
    
    enum AdditionalProcessResult {
        case failed(error: RequestError)
        case succes(result: [T])
    }
    
    let fetchCount = 20
    let lastUpdatedAtKey = "updatedAt"
    let createdAtKey = "createdAt"

    private let db = Firestore.firestore()
    let userIdKey = "userUID"
    private var listener: ListenerRegistration?
    private var document: DocumentReference?
    
    var id: String {
        return ""
    }
    var path: String {
        return ""
    }
    var fetchUniversal: Bool {
        return false
    }
    var dependencies: [RequesterBase] {
        return []
    }
    var fetchAll: Bool {
        return true
    }
    var body: [T] = []
    var requestMethod: RequestMethod = .get
    var isRequesting = false
    var notifyRequestManager: ((RequestResult) -> Void)?
    var observers: [RequesterObserver1] = []
    
    func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
        return nil
    }
    
    func fetch() {
        guard !isRequesting else {
            print("not requesting \(id)")
            return
        }
        isRequesting = true
        Queues.main.async {
            self.observers.forEach({ $0.requesterDidStart() })
        }
        print("--> Requested fetch - \(self)")
        requestMethod = .get
        RequestManager.addRequester(requester: self)
    }
    
    func submit(_ entity: [T], requestMethod: RequestMethod) {
        guard !isRequesting, entity.count > 0 else { return }
        print("--> Requested submit - \(self)")
        Queues.main.async {
            self.observers.forEach({ $0.requesterDidStart() })
        }
        body = entity
        self.requestMethod = requestMethod
        RequestManager.addRequester(requester: self)
    }
    
    func executeRequest() {
        guard hasInternet else {
            requestFailed(error: .notConnectedToNetwork)
            return
        }
        switch requestMethod {
        case .get: performFetch()
        case .put, .post, .delete: performSubmit()
        }
    }
    
    func prepareForSubmit(body: [T], completion:  @escaping ((AdditionalProcessResult) -> Void)) {
        completion(.succes(result: body))
    }
    
    func additionalProcessing(_ context: NSManagedObjectContext,_ entities: [T], completion: @escaping ((AdditionalProcessResult) -> Void)) {
        completion(.succes(result: entities))
    }
    
    func addObserver(_ controller: RequesterObserver1) {
        if observers.filter({ $0 === controller }).count == 0 {
            observers.append(controller)
        }
    }
    
    func removeObserver(_ controller: RequesterObserver1) {
        if let index = observers.firstIndex(where: {  $0 === controller }) {
            observers.remove(at: index)
        }
    }
    
    func addFetchingParamsFor(userId: String, context: NSManagedObjectContext, collection: inout Query) {
        if let lastUpdatedAt = self.getLastUpdatedAt(moc: context) {
            collection = self.db.collection(self.path).whereField(self.userIdKey, isEqualTo: userId).order(by: self.lastUpdatedAtKey, descending: false).whereField(self.lastUpdatedAtKey, isGreaterThan: lastUpdatedAt.intValue).limit(to: self.fetchCount)
        } else {
            collection = self.db.collection(self.path).whereField(self.userIdKey, isEqualTo: userId).order(by: self.lastUpdatedAtKey, descending: false).limit(to: self.fetchCount)
        }
    }
    
    private func performSubmit() {
        var documents = self.body
        var submittedDocuments: [T] = []
        
        func submitDocument(document: T) {
            if case .delete = self.requestMethod {
                if uploadSecret != nil {
                    document.rootDeleteDate = Date()
                } else {
                    document.deleteDate = NSDate()
                }
            }
            document.updatedAt = NSDate()
            do {
                let data = try JSONEncoder().encode(document)
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                    self.requestFailed(error: .failedEncoding(requester: self.id))
                    return
                }
                
                DispatchQueue.global(qos: .background).async {
                    self.db.collection(self.path).document(document.id).setData(json) { (error) in
                        if let error = error {
                            Queues.main.async {
                                self.requestFailed(error: .errorOnFireBase(requester: self.id, error: error))
                            }
                        } else {
                            document.id = self.db.collection(self.path).document(document.id).documentID
                            submittedDocuments.append(document)
                            documents.removeFirst()
                            if let document = documents.first {
                                submitDocument(document: document)
                            } else {
                                Store.persistentContainer.performBackgroundTask { (context) in
                                    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                                    self.additionalProcessing(context, submittedDocuments) { (result) in
                                        
                                        switch result {
                                        case .failed(error: let error):
                                            Queues.main.async {
                                                self.requestFailed(error: error)
                                            }
                                        case .succes(result: let result):
                                            Queues.main.async {
                                                result.forEach({
                                                    if $0.updatedAt == nil {
                                                        $0.updatedAt = $0.createdAt
                                                    }
                                                })
                                                context.perform {
                                                    DispatchQueue.main.sync {
//                                                        result.forEach({ $0.getManagedObject(context: context) })
                                                    }
                                                    do {
                                                        try context.save()
                                                        try moc.save()
                                                        Queues.main.async {
                                                            self.requestFinished(result: result)
                                                        }
                                                    } catch {
                                                        Queues.main.async {
                                                            self.requestFailed(error: .failedDecoding(requester: self.id))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            } catch {
                self.requestFailed(error: .failedEncoding(requester: self.id))
                return
            }
        }
        
        
        
        self.prepareForSubmit(body: self.body) { (result) in
            switch result {
            case .failed(error: let error): self.requestFailed(error: error)
            case .succes(result: let result):
                documents = result
                if let document = documents.first {
                    submitDocument(document: document)
                }
            }
        }
    }
    
    private func performFetch() {
        let backgroundContext = newMOCBackground
        backgroundContext.perform {
            if let userId = Auth.auth().currentUser?.uid {
                var collection: Query = Firestore.firestore().collection(self.path)
                self.addFetchingParamsFor(userId: userId, context: backgroundContext, collection: &collection)
                collection.getDocuments(source: .server) { (snapshot, error) in
                    if let error = error {
                        self.requestFailed(error: .errorOnFireBase(requester: self.id, error: error))
                    } else if let snapshot = snapshot {
                        do {
                            let entities: [T] = try snapshot.decoded()
                            
                            self.additionalProcessing(backgroundContext, entities) { (result) in
                                
                                switch result {
                                case .failed(error: let error):
                                    self.requestFailed(error: error)
                                case .succes(result: let result):
                                    if !(self is UiversalClusterFetcher) {
//                                        result.forEach({ $0.getManagedObject(context: backgroundContext) })
                                        if backgroundContext.hasChanges {
                                            do {
                                                try backgroundContext.save()
                                            } catch {
                                                self.requestFailed(error: .failedFetchingSavingCoreData(requester: self.id, error: error))
                                            }
                                            DispatchQueue.main.async {
                                                do {
                                                    try moc.save()
                                                } catch {
                                                    self.requestFailed(error: .failedFetchingSavingCoreData(requester: self.id, error: error))
                                                }
                                            }
                                        }
                                    }
                                    if result.count > 0, self.fetchAll {
                                        Queues.main.async {
                                            self.observers.forEach({ $0.requesterDidFinish(requester: self, result: .success(result), isPartial: true) })
                                        }
                                        self.performFetch() // max \(fetchCount) per fetch, continue fetching
                                    } else {
                                        Queues.main.async {
                                            self.requestFinished(result: result)
                                        }
                                    }
                                }
                            }
                        } catch {
                            Queues.main.async {
                                self.requestFailed(error: RequestError.failedDecoding(requester: self.id))
                            }
                        }
                    } else {
                        Queues.main.async {
                            self.requestFinished(result: [])
                        }
                    }
                }
                
            } else {
                Queues.main.async {
                    self.requestFailed(error: RequestError.unAuthorizedNoUser(requester: self.id))
                }
            }
        }
    }
    
    private func requestFailed(error: RequestError) {
        if (self is UiversalClusterFetcher) {
            NotificationCenter.default.post(name: .universalClusterSubmitterDidFinish, object: error)
        }
        if Thread.isMainThread {
            self.observers.forEach({ $0.requesterDidFinish(requester: self, result: .failed(error), isPartial: false) })
        } else {
            Queues.main.async {
                self.observers.forEach({ $0.requesterDidFinish(requester: self, result: .failed(error), isPartial: false) })
            }
        }
    }
    
    private func requestFinished(result: [T]) {
        if (self is UiversalClusterFetcher) {
            NotificationCenter.default.post(name: .universalClusterSubmitterDidFinish, object: nil)
        }
        func handleObservers() {
            let observers = self.observers.filter({ $0 is SingleRequestOperation })
            if observers.count > 0 {
                observers.forEach({ $0.requesterDidFinish(requester: self, result: .success(result), isPartial: false) })
            } else {
                self.observers.forEach({ $0.requesterDidFinish(requester: self, result: .success(result), isPartial: false) })
            }
        }
        if Thread.isMainThread {
            handleObservers()
        } else {
            Queues.main.async {
                handleObservers()
            }
        }
    }
    
}

protocol RequesterBase: class {
    var id: String { get }
    var isRequesting: Bool { get set }
    var notifyRequestManager: ((RequestResult) -> Void)? { get set }
    var dependencies: [RequesterBase] { get }
    var observers: [RequesterObserver1] { get }
    
    func executeRequest()
    func addObserver(_ controller: RequesterObserver1)
    func removeObserver(_ controller: RequesterObserver1)
}
