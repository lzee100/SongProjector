//
//  File.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//
import Foundation

let BaseRestService = BaseRS()


class Queues: NSObject {
	static var background: DispatchQueue {
		return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
	}
	static var main: DispatchQueue {
		return DispatchQueue.main
	}
}

class BaseRS: NSObject {
	
	
	struct Parameters {
		static let Additional = "additional"
	}
	
	struct Constants {
		static let ContentTypeKey = "Content-Type"
		static let AcceptTypeKey = "Accept"
	}
	
	let contentType: String = {
		let version = ChurchBeamConfiguration.RestServiceVersion
		return "application/json; charset=utf-8"
	}()
	
	private(set) var isOperationFinished: Bool = false
	
	func createHeaderParameters() -> [String: String] {
		var header: [String: String] = [:]
		if let orgId = CoreOrganization.getEntities().first?.id {
			header["organizationId"] = "\(orgId)"
		}
		return header
	}
	
	func addAuthorisation(_ request: RequestOperation) {
		CoreUser.managedObjectContext = mocBackground
		if CoreUser.getEntities().first?.appInstallToken != nil {
			
			request.authorization = AccountStore.icloudID

		}
		request.authorization = AccountStore.icloudID
	}
	
	
	
	// MARK: - methods
	func dispatchRequest(_ method: RequestMethod, url: String, inputBody: Data?, parameters: [String: Any]?, range: CountableRange<Int>?, success: @escaping (_ response: HTTPURLResponse?, _ data: Data?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ data: Data?) -> Void, queue: DispatchQueue) {
		
		Queues.background.async {
			self.requestDispatched(method, url: url, inputBody: inputBody, parameters: parameters, range: range, success: success, failure: failure, queue: queue)
		}
	}
	
	fileprivate func requestDispatched(_ method: RequestMethod, url: String, inputBody: Data?, parameters: [String: Any]?, range: CountableRange<Int>?, success: @escaping (_ response: HTTPURLResponse?, _ data: Data?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ data: Data?) -> Void, queue: DispatchQueue) {
		
		if let url = URL.fromString(url, parameters: parameters) {
			
			let operation = RequestOperation(method: method, url: url, batched: false, body: inputBody)
			let headers = createHeaderParameters()
			
			operation.accept = contentType
			operation.contentType = contentType
			operation.httpHeaderFields = headers
			operation.range = range
			operation.batched = false
			operation.userAgent = UserDefaults.standard.string(forKey: "UserAgent")
			
			addAuthorisation(operation)
			
			let fetchIcloudIdOperation = FetchIdOperation()
			
			let finishOperation = BlockOperation {
				self.isOperationFinished = true
				queue.async {
					if fetchIcloudIdOperation.isSuccess, operation.isSuccess, let response = operation.responses.first {
						success(response, operation.output?.first)
					} else {
						if let error = fetchIcloudIdOperation.error {
							failure(error as NSError?, nil, nil)
						} else {
							failure(operation.error as NSError?, operation.responses.first, operation.output?.first)
						}
						
					}
				}
			}
			
			let finishOperationIcloudId = BlockOperation {
				self.isOperationFinished = true
				if fetchIcloudIdOperation.isSuccess {
					let operations : [Foundation.Operation] = [operation, finishOperation]
					Operation.dependenciesInOrder(operations)
					Operation.Queue.addOperations(operations, waitUntilFinished: false)
				} else {
					failure(NSError(domain: "No icloud account is configured", code: -1, userInfo: nil), nil, nil)
				}
			}
			
			self.isOperationFinished = false
			let operations : [Foundation.Operation] = [fetchIcloudIdOperation, finishOperationIcloudId]
			Operation.dependenciesInOrder(operations)
			Operation.Queue.addOperations(operations, waitUntilFinished: true)
			
		} else {
			print("Failed create base URL for call: \n\( url)")
			failure(nil, nil, nil)
		}
	}
	
	//	fileprivate func recordError(_ error: NSError?, request: URLRequest?, response: HTTPURLResponse?, data: Data?) {
	//
	//		var dict: [String: Any] = [:]
	//
	//		if let data = data, let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
	//			dict["data"] = dataString
	//		}
	//		if let code = response?.statusCode {
	//			dict["statuscode"] = "\(code)" as AnyObject?
	//		}
	//		if let url = request?.url?.absoluteString {
	//			dict["url"] = url
	//		}
	//		if let error = error {
	//			dict["error"] = error
	//		}
	//
	//		Metrics.Error.fireError(NSError(domain: "REST Call Error", code: response?.statusCode ?? 0, userInfo: dict))
	//	}
	
	func decode<O: Decodable>(data: Data?) throws -> [O] {
		
		var result : [O] = []
		if let data = data {
			
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
			try json?.forEach({ json in
				let data = try JSONSerialization.data(withJSONObject: json, options: [])
				let myResult = try JSONDecoder().decode(O.self, from: data)
				result.append(myResult)
			})
		}
		
		return result
	}
	
	func decodeSingle<O: Decodable>(data: Data?) -> O? {
		
		var result: O? = nil
		if let data = data {
			do {
				result = try JSONDecoder().decode(O.self, from: data)
			} catch (let error){
				print("Error \(error)")
				return nil
			}
		}
		return result
	}
}
