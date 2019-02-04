//
//  RequestOperation.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//
import Foundation

public enum RequestMethod : String {
	case get = "GET"
	case post = "POST" // new
	case put = "PUT" // update
	case delete = "DELETE"
}

public protocol ShiftOutOperation : AnyObject {
	
	associatedtype OutputType
	var output : OutputType? { get }
	
}

open class RequestOperation : AsynchronousOperation, ShiftOutOperation {
	
	// MARK: - Private Properties
	
	private var task : URLSessionTask?
	
	private var buffer : [Data] = []
	
	
	
	// MARK: - Properties
	
	public let url : URL
	public var output : [Data]?
	
	public var method = RequestMethod.get
	public var range : CountableRange<Int>? = 0..<100
	public var batched = true
	public var body : Data?
	public var accept : String?
	public var contentType : String?
	public var parameters : [String : [String]] = [:]
	public var httpHeaderFields : [String: String] = [:]
	public var authorization : String?
	public var accessToken : String?
	public var userAgent : String?
	
	public private(set) var responses : [HTTPURLResponse] = []
	public private(set) var error : Error?
	
	public var isSuccess : Bool {
		
		return responses.count > 0 && responses.reduce(true, {
			(value, response) in
			return value && ( HTTPStatus.from(response.statusCode)?.isSuccess == true )
		})
		
	}
	
	// MARK: - Construction
	
	public init(method: RequestMethod = .get, url: URL, batched: Bool, parameters: [String: [String]] = [:], body: Data? = nil) {
		
		self.url = url
		self.method = method
		self.batched = batched
		self.parameters = parameters
		self.body = body
		
	}
	
	// MARK: - Functions
	
	override open func main() {
		
		request()
		
	}
	
	open override func cancel() {
		
		task?.cancel()
		super.cancel()
		
	}
	
	open func request(){
		
		var url = self.url
		
		//Add parameters
		url.append(parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value.joined(separator: ",")) })
		
		//Create request
		let session = createUrlSession()
		
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		
		for field in httpHeaderFields {
			request.addValue(field.value, forHTTPHeaderField: field.key)
		}
		
		//Set headers
		if let range = range {
			request.addValue("items=\(range.startIndex)-\(range.endIndex)", forHTTPHeaderField: "Range")
		}
		
		if let accept = accept {
			request.addValue(accept, forHTTPHeaderField: "Accept")
		}
		
		if let authorization = authorization {
			request.setValue(authorization, forHTTPHeaderField: "Authorization")
		} else if let accessToken = accessToken {
			request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		}
		
		if let contentType = contentType{
			request.addValue(contentType, forHTTPHeaderField: "Content-Type")
		}
		if let userAgent = userAgent {
			request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
		}
		if let body = body {
			request.httpBody = body
		}
		
		var requestPrint = "Requesting '\(method.rawValue):\(url.absoluteString)'"
		if let range = range {
			requestPrint += " (\(range.startIndex)-\(range.endIndex))"
		}
		print(requestPrint)
		
		let task = createTask(session: session, request: request)
		
		self.task = task
		task.resume()
		session.finishTasksAndInvalidate()
	}
	
	open func createTask(session : URLSession, request : URLRequest) -> URLSessionTask {
		
		return session.dataTask(with: request) { [weak self]
			(data, response, error) in
			self?.onResponse(data: data, response: response, error: error)
		}
	}
	
	public func onResponse(data : Data?, response : URLResponse?, error : Error?){
		if let error = error {
			
			self.error = error
			print("Request failed: \(error.localizedDescription)")
			self.didFail()
			
		} else if let response = response as? HTTPURLResponse {
			
			self.responses.append(response)
			
			if let data = data {
				
				self.buffer.append(data)
				
				if let range = self.range, response.isPartial && self.batched {
					self.range = range.next()
					self.request()
				} else {
					self.output = self.buffer
					self.didFinish()
				}
				
			} else {
				self.didFinish()
			}
			
		}
	}
	
	open func createUrlSession() -> URLSession{
		return URLSession(
			configuration: .default,
			delegate: nil,
			delegateQueue: Operation.Queue
		)
	}
	
}

extension CountableRange {
	
	public func next() -> CountableRange<Element>{
		let distance = startIndex.distance(to: endIndex)
		return endIndex..<endIndex.advanced(by: distance)
	}
	
}
