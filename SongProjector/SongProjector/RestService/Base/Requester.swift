//
//  Requester.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct RestError: Decodable {
	let errorMessage: String
	
	enum CodingKeys: String, CodingKey
	{
		case error
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		errorMessage = try container.decodeIfPresent(String.self, forKey: .error) ?? "no error message default"
	}
	
}

struct RequesterOperations: Equatable {
	
	let requester: RequesterDependency
	let operations: [Foundation.Operation]
	
	static func == (lhs: RequesterOperations, rhs: RequesterOperations) -> Bool {
		return lhs.requester.requesterId == rhs.requester.requesterId
	}
	
}

let SuperRequester = SperRequester()

class SperRequester: NSObject {
	
	private var unsafeRequesterOperations: [RequesterOperations] = []

	private var safeRequesterOperations: [RequesterOperations] {
		var safeAllCounters: [RequesterOperations]!
		concurrentUnreadCountQueue.sync {
			safeAllCounters = self.unsafeRequesterOperations
		}
		return safeAllCounters
	}
	
	private let concurrentUnreadCountQueue =
		DispatchQueue(
			label: "oneThreadUnreadCount",
			attributes: .concurrent)

	func request(requester: RequesterDependency, dependencies: [RequesterDependency]) {
		let allRequestsOperation = AllRequestsOperation()
		allRequestsOperation.requesterDependencies = dependencies
		allRequestsOperation.requester = requester

		let finishOperation = BlockOperation {
			if let index = self.unsafeRequesterOperations.firstIndex(where: { $0.requester.isSuperRequesterTotalFinished }) {
				self.saveDeleteRequester(at: index)
			}
			requester.observers.forEach({ $0.requestDidFinish(requesterID: requester.requesterId, response: allRequestsOperation.responseType, result: allRequestsOperation.result) })
		}
		
		let operations = [allRequestsOperation, finishOperation]
		Operation.dependenciesInOrder(operations)
		
		unsafeRequesterOperations.append(RequesterOperations(requester: requester, operations: operations))
		
		Operation.GlobalQueue.addOperations(operations, waitUntilFinished: false)
	}
	
	private func saveDeleteRequester(at index: Int) {
		concurrentUnreadCountQueue.async(flags: .barrier) {
			self.unsafeRequesterOperations.remove(at: index)
		}
	}

	
}

class AllRequestsOperation: AsynchronousOperation, RequestObserver {
	
	var requesterId: String = "AllRequestsOperation"
	var requesterDependencies: [RequesterDependency] = []
	var requester: RequesterDependency!
	var responseType: ResponseType!
	var result: AnyObject? = nil
	
	override func main() {
		print("###################")
		print("executing \(requester!)")
		print("dependencies \(requesterDependencies)")
		requesterDependencies.forEach({ $0.isSuperRequesterFinished = false })
		requester.isSuperRequesterFinished = false
		requester.isSuperRequesterTotalFinished = false
		executeAllRequesters()
	}
	
	private func executeAllRequesters() {
		if let requester = requesterDependencies.first(where: { !$0.isSuperRequesterFinished }) {
			requester.addObserver(self)
			requester.request(isSuperRequester: true)
		} else {
			requester.isSuperRequesterTotalFinished = true
			didFinish()
		}
	}
	
	func requesterDidStart() {
		
	}
	
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		self.responseType = response
		if requesterID == requester.requesterId {
			self.result = result
		}
		let current = requesterDependencies.first(where: { $0.requesterId == requesterID })
		current?.isSuperRequesterFinished = true
		current?.removeObserver(self)
		switch response {
		case .error(_, _):
			requesterDependencies.forEach({ $0.isSuperRequesterFinished = true })
			requester.isSuperRequesterTotalFinished = true
			didFail()
		case .OK(_):
			executeAllRequesters()
		}
	}
	
	
}

class Requester<T>: BaseRS, RequesterType, RequesterDependency where T: VEntity {
	
	enum AdditionalProcessResult {
		case failed(error: Error)
		case succes(result: [T])
	}
		
	// MARK: - Properties
	
	var requesterId: String {
		return "Requester"
	}
	var requestMethod: RequestMethod = .get
	
	var isFinished: Bool {
		return super.isOperationFinished
	}
	
	var path: String {
		return ""
	}
	
	var suffix: String {
		return ""
	}
	
	var isSuperRequesterIsFinished = false

	var parent: RequesterDependency? = nil
	var dependencies: [RequesterDependency] {
		return []
	}
	
	var isSuperRequesterTotalFinished = true  // all dependencies and requester are fetched
	var isSuperRequesterFinished = false // Super requester fetched this one
	
	var observers: [RequestObserver] = []

	var params: [String: Any] {
		return [:]
	}
	
	var range: CountableRange = CountableRange(0...200)
	
	var body: [T]?
	
	private var isSubmitter: Bool {
		return requestMethod != .get
	}
	
	
	// MARK: - Functions
	
	func addObserver(_ controller: RequestObserver) {
		if observers.filter({ $0 === controller }).count == 0 {
			observers.append(controller)
		}
	}
	
	func removeObserver(_ controller: RequestObserver) {
		if let index = observers.firstIndex(where: {  $0 === controller }) {
			observers.remove(at: index)
		}
	}
	
	func setParent(_ parent: RequesterDependency) {
		self.parent = parent
	}
	
	func request(isSuperRequester: Bool) {
		if isSuperRequester {
			executeRequest()
		} else {
			setupSuperRequester(dependencies, for: self)
		}
	}
	
	func submit(_ entity: [T], requestMethod: RequestMethod) {
		body = entity
		self.requestMethod = requestMethod
		self.request(isSuperRequester: false)
	}
	
	private func executeRequest() {
		
		if path == "" {
			let error = NSError(domain: "No object id found for: \(requesterId)", code: 0, userInfo: nil)
			print(error)
			requestFinished(response: .error(nil, error as Error), result: nil)
			return
		}
		
		let url = ChurchBeamConfiguration.environment.endpoint + path + suffix
		
		if requestMethod == .get {
			
			requestGet(url:  url, parameters: params, success: { (response, result) in
				self.requestFinished(response: .OK(.updated), result: result)
			}, failure: { (error, response, result) in
				let restError = error ?? (result != nil ? NSError(domain: result!.errorMessage, code: 0, userInfo: nil) : nil)
				self.requestFinished(response: .error(response, restError), result: nil)
			}, queue: Queues.background)
			
		} else {
			
			// do uploads
			prepareForSend(body: body ?? []) { (result) in
				
				switch result {
				
				case .failed(error: let error):
					self.requestFinished(response: .error(nil, error), result: nil)
				
				case .succes(result: let result):
					self.requestSend(url: url, object: result, parameters: self.params, range: self.range, success: { (resonpse, result) in
						var saveResult: [T]? = nil
						if let result = result {
							saveResult = result
						}
						self.requestFinished(response: .OK(.updated), result: saveResult)
					}, failure: { (error, response, result) in
						let restError = error ?? (result != nil ? NSError(domain: result!.errorMessage, code: 0, userInfo: nil) : nil)
						self.requestFinished(response: .error(response, restError), result: nil)
					}, queue: Queues.background)
				}
				
			}
		}
		
	}
	
	func requesterDidStart() {
	}
	
	func prepareForSend(body: [T], completion:  @escaping ((AdditionalProcessResult) -> Void)) {
		completion(.succes(result: body))
	}
	
	func additionalProcessing(_ context: NSManagedObjectContext,_ entities: [T], completion: @escaping ((AdditionalProcessResult) -> Void)) {
		completion(.succes(result: entities))
	}
	
	func requestFinished(response: ResponseType, result: [T]?) {
		body = nil
		switch response {
		case .OK(let action):
			print("----------------------")
			print(requesterId + ": \(action)")
		case .error( _, let error): print(requesterId + ": error - \(String(describing: error))")

		}
		Queues.main.async {
			self.observers.first(where: { $0.requesterId == "AllRequestsOperation" })?.requestDidFinish(requesterID: self.requesterId, response: response, result: result as AnyObject)
		}
	}
	
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		
	}
	
	func requestGet(_ method: RequestMethod = .get, url: String, parameters: [String: Any]?, range: CountableRange<Int>? = nil, success: @escaping (_ response: HTTPURLResponse?, _ result: [T]?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ object: RestError?) -> Void, queue: DispatchQueue) {
		
		super.dispatchRequest(method, url: url, inputBody: nil, parameters: parameters, range: range, success: {  (response, data) -> Void in
			
			data?.printToJson()
			
			var result : [T] = []
			if let data = data {
				do {
					result = try JSONDecoder().decode([T].self, from: data)
					Store.persistentContainer.performBackgroundTask { (context) in
						context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
						self.additionalProcessing(context, result) { (result) in
							
							switch result {
								
							case .failed(error: let error):
								failure(error as NSError, nil, nil)
								
							case .succes(result: let result):
								result.forEach({ $0.getManagedObject(context: context) })
								do {
									try context.save()
									success(response, result)
								} catch {
									print("Error \(error)")
									failure(error as NSError, nil, nil)
								}
							}
							
						}
					}
				} catch {
					print("Error \(error)")
					failure(error as NSError, nil, nil)
				}
			} else {
				success(response, result)
			}
		}, failure: {  (error, response, data) -> Void in
			let restError: RestError? = super.decodeSingle(data: data)
			failure(error, response, restError)
			
		}, queue: queue)
	}
	

	func requestSend<O: Encodable>(url: String, object: [O]?, parameters: [String: Any]?, range: CountableRange<Int>? = nil, success: @escaping (_ response: HTTPURLResponse?, _ result: [T]?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ object: RestError?) -> Void, queue: DispatchQueue) {
		
		var inputBody: Data? = nil
		if let object = object {
			do {
				inputBody = try JSONEncoder().encode(object)
			} catch {
				failure(NSError(domain: "object is not encodable", code: 0, userInfo: nil), nil, nil)
			}
		}

		print("--------------printing posting \(String(describing: object?.first.debugDescription))")
		inputBody?.printToJson()
				
		super.dispatchRequest(self.requestMethod, url: url, inputBody: inputBody, parameters: parameters, range: range, success: {  (response, data) -> Void in
			
//			print("---------------data returned from posting \(String(describing: object?.first.debugDescription))")
//			data?.printToJson()
			
			var result : [T] = []
			if let data = data {
				do {
					result = try JSONDecoder().decode([T].self, from: data)
					Store.persistentContainer.performBackgroundTask { (context) in
						self.additionalProcessing(context, result) { result in
							
							switch result {
								
							case .failed(error: let error):
								failure(error as NSError, nil, nil)
								
							case .succes(result: let result):
								result.forEach({ $0.getManagedObject(context: context) })
								do {
									try context.save()
									success(response, result)
								} catch {
									print("Error \(error)")
									failure(error as NSError, nil, nil)
								}
							}
							
						}
					}
				} catch (let error){
					print("Error \(error)")
					failure(error as NSError, nil, nil)
				}
			} else {
				success(response, result)
			}
			
		}, failure: {   (error, response, data) -> Void in
			
			let restError: RestError? = super.decodeSingle(data: data)
			
			failure(error, response, restError)
			
		}, queue: queue)
	}
	
	private func setupSuperRequester(_ dependencies: [RequesterDependency], for parent: RequesterDependency) {

		var allDependencies = [parent]
		
		dependencies.forEach { (dependency) in
			allDependencies.append(dependency)
			dependency.dependencies.forEach({
				allDependencies.append($0)
			})
		}
		allDependencies = allDependencies.reversed()
		
		SuperRequester.request(requester: parent, dependencies: allDependencies)
		
	}
}

protocol RequesterDependency: NSObject {
	var requesterId: String { get }
	var observers: [RequestObserver] { get set }
	var dependencies: [RequesterDependency] { get }
	func addObserver(_ controller: RequestObserver)
	func removeObserver(_ controller: RequestObserver)
	var isSuperRequesterTotalFinished: Bool { get set }  // all dependencies and requester are fetched
	var isSuperRequesterFinished: Bool { get set } // Super requester fetched this one

	var isFinished: Bool { get }
	
	func request(isSuperRequester: Bool)
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?)

}

protocol RequesterType {
	
	var requesterId: String { get }
	var observers: [RequestObserver] { get set }
	
	func requesterDidStart()
	func addObserver(_ controller: RequestObserver)
	func removeObserver(_ controller: RequestObserver)
	func request(isSuperRequester: Bool)
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?)

}

protocol RequestObserver: NSObject {
	var requesterId: String { get }
	func requesterDidStart()
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?)
}

enum ResultOkType {
	case notUpdated
	case updated
}

enum ResponseType {
	case OK(ResultOkType)
	case error(HTTPURLResponse?, Error?)
}
