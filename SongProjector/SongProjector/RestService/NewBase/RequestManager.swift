////
////  RequestManager.swift
////  SongProjector
////
////  Created by Leo van der Zee on 31/05/2020.
////  Copyright © 2020 iozee. All rights reserved.
////
//
//import Foundation
//
//let RequestManager = RquestManager()
//
//class RquestManager: NSObject {
//
//    private var unsafeRequesterOperations: [(RequesterBase, [RequesterBase])] = [] {
//        didSet {
//            if unsafeRequesterOperations.count == 1, let first = unsafeRequesterOperations.first {
//                self.unsafeRequesterOperations.removeFirst()
//                print("-----> starting request \(first.0.self)")
//                Queues.main.async {
//                    self.request(uniqueRequesters: first.1, requester: first.0)
//                }
//            }
//        }
//    }
//
//    private var safeRequesterOperations: [(RequesterBase, [RequesterBase])] {
//        var safeRequesterOperations:[(RequesterBase, [RequesterBase])]!
//        concurrentUnreadCountQueue.sync {
//            safeRequesterOperations = self.unsafeRequesterOperations
//        }
//        return safeRequesterOperations
//    }
//
//    private let concurrentUnreadCountQueue =
//        DispatchQueue(
//            label: "oneThreadUnreadCount",
//            attributes: .concurrent)
//
//
//    func startRequest(requester: RequesterBase) {
//
//        var requesters: [RequesterBase] = [requester]
//
//        func addDependency(_ requester: RequesterBase) {
//            requesters += requester.dependencies
//            requester.dependencies.forEach({ addDependency($0) })
//        }
//        addDependency(requester)
//        requesters = requesters.unique(on: { $0 === $1 }).reversed()
//        addToRequestOperation(requests: (requester, requesters))
//    }
//
//    private func request(uniqueRequesters: [RequesterBase], requester: RequesterBase) {
//        var toDo: [RequesterBase] = uniqueRequesters
//        toDo.forEach({ $0.isRequesting = true })
//        func requesterFinished(_ result: RequestResult) {
//            switch result {
//            case .failed(let error ):
//                toDo.first?.observers.forEach({ $0.requesterDidFinish(requester: requester, result: .failed(error), isPartial: false) })
//                requester.notifyRequestManager = nil
//                uniqueRequesters.forEach({ $0.isRequesting = false })
//                finish()
//            case .success(let result):
//                if toDo.count > 0 {
//                    toDo.remove(at: 0)
//                }
//                if toDo.count > 0 {
//                    beginRequest()
//                } else {
//                    Queues.main.async {
//                        requester.notifyRequestManager = nil
//                        requester.observers.forEach({ $0.requesterDidFinish(requester: requester, result: .success(result), isPartial: false) })
//                        uniqueRequesters.forEach({ $0.isRequesting = false })
//                        self.finish()
//                    }
//                }
//            }
//        }
//
//        func beginRequest() {
//            if let requester = toDo.first {
//                Queues.main.async {
//                    requester.notifyRequestManager = requesterFinished
//                    requester.executeRequest()
//                }
//            }
//        }
//
//        beginRequest()
//    }
//
//    private func saveDeleteFirstRequestOperation() {
//        concurrentUnreadCountQueue.async(flags: .barrier) {
//            guard self.unsafeRequesterOperations.count > 0 else {
//                return
//            }
//            self.unsafeRequesterOperations.remove(at: 0)
//        }
//    }
//
//    private func addToRequestOperation(requests: (RequesterBase, [RequesterBase])) {
//        concurrentUnreadCountQueue.async(flags: .barrier) {
//            self.unsafeRequesterOperations.append(requests)
//        }
//    }
//
//
//    private func finish() {
//        saveDeleteFirstRequestOperation()
//        if let next = self.safeRequesterOperations.first {
//            self.request(uniqueRequesters: next.1, requester: next.0)
//        }
//    }
//
//}
