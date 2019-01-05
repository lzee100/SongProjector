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
		return "application/vnd.topicus.geon+json;version=\(version)"
	}()
	
	func createHeaderParameters() -> [String: String] {
		return [:]
	}
	
	func addAuthorisation(_ request: RequestOperation) {
//		if let password = password{
//			return "Basic " + ("\(username):\(password)".base64Encoded)
//		} else{
//			return OAuthStore.authorizationHeader()
//		}
		request.authorization = "Basic unknown"
	}
	
	func request<E: Mappable>(_ method: RequestMethod, url: String, parameters: [String: Any]?, range: CountableRange<Int>? = nil, success: @escaping (_ response: HTTPURLResponse?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ object: E?) -> Void, context:AuthContext? = nil, queue: DispatchQueue) {
		
		self.dispatchRequest(method, url: url, inputBody: nil, parameters: parameters, range: range, success: {   (response, data) -> Void in
			
			success(response)
			
		}, failure: {   (error, response, data) -> Void in
			
			failure(error, response, ObjectMapping.mapSingle(data: data))
			
		}, context:context, queue: queue)
	}
	
	
	func request<O: Decodable, E: Decodable>(_ method: RequestMethod, url: String, parameters: [String: Any]?, range: CountableRange<Int>? = nil, success: @escaping (_ response: HTTPURLResponse?, _ result: O?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ object: E?) -> Void, context:AuthContext? = nil, queue: DispatchQueue) {
		
		self.dispatchRequest(method, url: url, inputBody: nil, parameters: parameters, range: range, success: {  (response, data) -> Void in
			
			success(response, ObjectMapping.mapSingle(data: data))
			
		}, failure: {  (error, response, data) -> Void in
			
			failure(error, response, ObjectMapping.mapSingle(data: data))
			
		}, context:context, queue: queue)
	}
	
	func request<I: Encodable, O: Decodable, E: Decodable>(_ method: RequestMethod, url: String, object: I?, parameters: [String: Any]?, range: CountableRange<Int>? = nil, success: @escaping (_ response: HTTPURLResponse?, _ result: O?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ object: E?) -> Void, queue: DispatchQueue) {
		
		var inputBody: Data? = nil
		if let object = object {
			do {
				inputBody = try JSONEncoder().encode(object)
			} catch {
				failure(NSError(domain: "object is not encodable", code: 0, userInfo: nil), nil, nil)
			}
		}
		
		self.dispatchRequest(method, url: url, inputBody: inputBody, parameters: parameters, range: range, success: {  (response, data) -> Void in
			
			let result : O?
			if let data = data {
				result = JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: data)
			}
			success(response, result)
			
			
		}, failure: {   (error, response, data) -> Void in
			
			let object: E? = ObjectMapping.mapSingle(data: data)
			
			if let object = object, let json = object.toJSONString(prettyPrint: true) {
				BaseRestService.logger.error(json)
			}
			
			failure(error, response, object)
			
		}, queue: queue)
	}
	
	// MARK: - private methods
	fileprivate func dispatchRequest(_ method: RequestMethod, url: String, inputBody: Data?, parameters: [String: Any]?, range: CountableRange<Int>?, success: @escaping (_ response: HTTPURLResponse?, _ data: Data?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ data: Data?) -> Void, queue: DispatchQueue) {
		
		Queues.background.async {
			self.requestDispatched(method, url: url, inputBody: inputBody, parameters: parameters, range: range, success: success, failure: failure, queue: queue)
		}
	}
	
	private func prettyPrint(with json: [String:Any]) -> String{
		let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
		return string! as String
	}
	
	fileprivate func requestDispatched(_ method: RequestMethod, url: String, inputBody: Data?, parameters: [String: Any]?, range: CountableRange<Int>?, success: @escaping (_ response: HTTPURLResponse?, _ data: Data?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ data: Data?) -> Void, queue: DispatchQueue) {
		
		if let url = URL.fromString(url, parameters: parameters) {
			
			let operation = RequestOperation(method: method, url: url, batched: false, body: inputBody)
			let currentContext = AccountStore.currentContextId
			let authContext = AccountStore.currentAuthentication //context ?? currentContext?.authContext
			let headers = createHeaderParameters(using: authContext)
			
			operation.accept = contentType
			operation.contentType = contentType
			operation.httpHeaderFields = headers
			operation.range = range
			operation.batched = false
			operation.userAgent = UserDefaults.standard.string(forKey: "UserAgent")
			
			if let authContext = authContext{
				addAuthorisation(operation, using:authContext)
			}
			
			let finishOperation = BlockOperation {
				
				queue.async {
					
					if AccountStore.currentContextId == currentContext{
						if operation.isSuccess, let response = operation.responses.first {
							
							success(response, operation.output?.first)
						} else {
							
							failure(operation.error as NSError?, operation.responses.first, operation.output?.first)
						}
					}
				}
			}
			
			let operations : [Foundation.Operation] = [OAuthRefreshOperation(), operation, finishOperation]
			Operation.dependenciesInOrder(operations)
			Operation.Queue.addOperations(operations, waitUntilFinished: false)
			
		} else {
			
			Log.error("Failed create base URL for call: %@", url)
			failure(nil, nil, nil)
		}
	}
	
	fileprivate func recordError(_ error: NSError?, request: URLRequest?, response: HTTPURLResponse?, data: Data?) {
		
		var dict: [String: Any] = [:]
		
		if let data = data, let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
			dict["data"] = dataString
		}
		if let code = response?.statusCode {
			dict["statuscode"] = "\(code)" as AnyObject?
		}
		if let url = request?.url?.absoluteString {
			dict["url"] = url
		}
		if let error = error {
			dict["error"] = error
		}
		
		Metrics.Error.fireError(NSError(domain: "REST Call Error", code: response?.statusCode ?? 0, userInfo: dict))
	}
}

extension URL {
	
	static func fromString(_ url: String, parameters: [String: Any]?) -> URL? {
		
		if var components = URLComponents(string: url) {
			
			var queryItems: [URLQueryItem] = []
			for (key, value) in parameters ?? [:] {
				if let value = value as? String {
					queryItems.append(URLQueryItem(name: key, value: value))
					
				} else if let value = value as? NSNumber {
					queryItems.append(URLQueryItem(name: key, value: String(format: "%lld", value.int64Value)))
					
				} else if let value = value as? [String] {
					for val in value {
						queryItems.append(URLQueryItem(name: key, value: val))
					}
				} else if let value = value as? [NSNumber] {
					for val in value {
						queryItems.append(URLQueryItem(name: key, value: val.stringValue))
					}
				}
			}
			if queryItems.count > 0 {
				components.queryItems = queryItems
			}
			return components.url
		}
		return nil
	}
}
