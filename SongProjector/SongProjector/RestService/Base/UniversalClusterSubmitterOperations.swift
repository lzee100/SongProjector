//
//  UniversalClusterSubmitterOperations.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation


class UniversalClusterSubmitterOperations {
    
    private static var submitOperations: [AbstractUCSubmitOperation] = []
    
    static func addClustersToSubmit(clusters: [VCluster]) {
        
        NotificationCenter.default.addObserver(forName: .universalClusterSubmitterDidFinish, object: nil, queue: OperationQueue.current) { (not) in
            if let error = not.object as? RequestError {
                NotificationCenter.default.post(name: .universalClusterSubmitterFailed, object: error)
            } else {
                submitAllOperations()
            }
        }
        
        submitOperations.append(UCSubmitOperation(clusters: clusters))
        
    }
    
    static func addUUASubmit(uua: [VUniversalUpdatedAt]) {
        
        NotificationCenter.default.addObserver(forName: .universalClusterSubmitterDidFinish, object: nil, queue: OperationQueue.current) { (not) in
            if let error = not.object as? RequestError {
                NotificationCenter.default.post(name: .universalClusterSubmitterFailed, object: error)
            } else {
                submitAllOperations()
            }
        }
        
        submitOperations.append(UUAupdatedAtOperation(universalUpdatedAt: uua))
        
    }
    
    
    
    // - MARK: Private Functions
    
    private static func submitAllOperations() {
        let oneUUA = submitOperations.filter({ $0 is UUAupdatedAtOperation }).last
        let operations: [AbstractUCSubmitOperation] = (submitOperations.compactMap({ $0 as? UCSubmitOperation }) + [oneUUA]).compactMap({ $0 }).reversed()
        submitOperations = []
        var previousOperation: AbstractUCSubmitOperation?
        
//        var testFailure = 0
                
        for current in operations {
            if let preOperation = previousOperation {
                
//                if testFailure == 3 {
//                    current.error = .unknown(requester: "test", error: RequestError.unAuthorizedNoUser(requester: "test un"))
//                }
//                testFailure += 1
                
                preOperation.dependencyDidFail = current.operationDidFail
                preOperation.addDependency(current)
                previousOperation = current
            } else {
                previousOperation = current
            }
        }
        
        func finish() {
            if let error = operations.first?.error {
                NotificationCenter.default.post(name: .universalClusterSubmitterFailed, object: error)
            }
        }
        
        if let operation = operations.first {
            operation.completionBlock = finish
        }
        
        RequestManager.add(operations: operations)
        
    }
    
}

class UUAupdatedAtOperation: AbstractUCSubmitOperation {
    
    let submitter: UiversalClusterUpdatedAtSubmitter
    let body: [VUniversalUpdatedAt]
    
    init(universalUpdatedAt: [VUniversalUpdatedAt]) {
        submitter = UiversalClusterUpdatedAtSubmitter()
        body = universalUpdatedAt
        super.init()
    }
    
    override func main() {
        if let error = dependencyDidFail?() {
            self.error = error
            didFail()
            return
        }
        submitter.requestMethod = .post
        submitter.body = body
        submitter.addObserver(self)
        submitter.executeRequest()
    }
    
}

extension UUAupdatedAtOperation: RequesterObserver1 {
    
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        if !isPartial {
            switch result {
            case .failed(let error):
                self.error = error
                didFail()
            case .success(_):
                didFinish()
            }
        }
    }
    
}



class UCSubmitOperation: AbstractUCSubmitOperation {
    
    let submitter: CsterSubmitter
    let body: [VCluster]
    
    init(clusters: [VCluster]) {
        submitter = CsterSubmitter()
        body = clusters
        super.init()
    }
    
    override func main() {
        if let error = dependencyDidFail?() {
            self.error = error
            didFail()
            return
        }
        submitter.dontUploadFiles = true
        submitter.requestMethod = .post
        submitter.body = body
        submitter.addObserver(self)
        submitter.executeRequest()
    }
    
}

class AbstractUCSubmitOperation: AsynchronousOperation {

    var dependencyDidFail: (() -> RequestError?)?
    var error: RequestError?
    
    func operationDidFail() -> RequestError? {
        return error
    }
    
}


extension UCSubmitOperation: RequesterObserver1 {
    
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        if !isPartial {
            switch result {
            case .failed(let error):
                self.error = error
                didFail()
            case .success(_):
                didFinish()
            }
        }
    }
    
}
