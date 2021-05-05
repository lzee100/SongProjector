//
//  RequestManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/10/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let RequestManager = SerialOperationManager()

class SerialOperationManager {
    
    private let lockQueue: DispatchQueue = {
        let queue: DispatchQueue = .init(label: "lockQueue")
        return queue
    }()
    static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "RequestManagerQueue"
        return queue
    }()
    
    func addRequester(requester: RequesterBase) {
        lockQueue.async {
            NSRecursiveLock().lock()
            var requesters: [RequesterBase] = [requester]
            
            func addDependency(_ requester: RequesterBase) {
                requesters += requester.dependencies
                requester.dependencies.forEach({ addDependency($0) })
            }
            addDependency(requester)
            requesters = requesters.unique(on: { $0 === $1 })
            requesters.forEach({ $0.isRequesting = true })

            let operations = requesters.map({ SingleRequestOperation(requester: $0) })
            
            Operation.dependenciesInOrder(operations)
            SerialOperationManager.operationQueue.addOperations(operations, waitUntilFinished: true)
            NSRecursiveLock().unlock()
        }
    }
    
    func add(operations: [Foundation.Operation]) {
        lockQueue.async {
            NSRecursiveLock().lock()
            Operation.dependenciesInOrder(operations)
            SerialOperationManager.operationQueue.addOperations(operations, waitUntilFinished: true)
            NSRecursiveLock().unlock()
        }

    }
    
}

class SingleRequestOperation: AsynchronousOperation, RequesterObserver1  {
   
    
    let requester: RequesterBase
    var error: NSError?
    
    init(requester: RequesterBase) {
        self.requester = requester
    }
    
    override func main() {
        if let error = dependencies.compactMap({ $0 as? SingleRequestOperation }).filter({ $0.error != nil }).first?.error {
            print("--------------------------finished request (FAILED): \(requester)")
            setFailed(error: error)
        } else {
            print("--------------------------starting request: \(requester)")
            requester.addObserver(self)
            requester.executeRequest()
        }
    }
    
    func requesterDidStart() {
    }
    
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        var error: NSError? = nil
        switch result {
        case .failed(let err):
            error = err as NSError
        case .success(_): break
        }
        error = error ?? dependencies.compactMap({ $0 as? SingleRequestOperation }).compactMap({ $0.error }).first
        if let error = error {
            print("--------------------------finished request (FAILED): \(requester)")
            setFailed(error: error)
        } else {
            guard !isPartial else {
                return
            }
            print("--------------------------finished request: \(requester)")
            
            requester.removeObserver(self)
            requester.isRequesting = false
            requester.observers.forEach({ $0.requesterDidFinish(requester: requester, result: result, isPartial: isPartial) })
            switch result {
            case .failed(_): didFail()
            case .success(_): didFinish()
            }
        }
    }
    
    private func setFailed(error: Error) {
        requester.removeObserver(self)
        requester.isRequesting = false
        let localizedError = (error as? RequestError) ?? RequestError.unknown(requester: requester.id, error: error)
        requester.observers.forEach({ $0.requesterDidFinish(requester: requester, result: .failed(localizedError), isPartial: false) })
        didFail()
    }
    
    
}
