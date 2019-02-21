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


class Requester<T>: BaseRS, RequesterType, RequestObserver where T:Codable, T:NSManagedObject {
	
	
	
	// MARK: - Properties
	
	var requesterId: String {
		return "Requester"
	}
	var requestMethod: RequestMethod = .get
	
	var requestReloadTime: RequesterReloadTime {
		return .immidiate
	}
	
	var isFinished: Bool {
		return super.isOperationFinished
	}
	
	var requesterDependencies: [RequesterType] {
		return []
	}
	
	// /themes
	var path: String {
		return ""
	}
	
	var coreDataManager: CoreDataManager<T> {
		return CoreDataManager<T>()
	}
	
	var observers: [RequestObserver] = []
	
	var params: [String: Any] {
		return [:]
	}
	
	var range: CountableRange = CountableRange(0...200)
	
	var body: [T]?
	
	private(set) var minRefreshDate: Date = Date()
	
	private var needsUpdating : Bool {
		return minRefreshDate.isBefore(Date())
	}
	
	private var isSubmitter: Bool {
		return body != nil
	}
	
	private var forced: Bool = false
	
	
	
	// MARK: - Functions
	
	func addObserver(_ controller: RequestObserver) {
		if observers.filter({ $0.requesterId == controller.requesterId }).count == 0 {
			observers.append(controller)
		}
	}
	
	func removeObserver(_ controller: RequestObserver) {
		if let index = observers.firstIndex(where: {  $0.requesterId == controller.requesterId }) {
			observers.remove(at: index)
		}
	}
	
	func request(force: Bool) {
		if force || needsUpdating || isSubmitter {
			observers.forEach({ $0.requesterDidStart() })
			self.forced = force
			if requesterDependencies.count == 0 {
				executeRequest()
			} else {
				requesterDependencies.forEach({ $0.addObserver(self) })
				requesterDependencies.forEach({ $0.request(force: true) })
			}
		} else {
			requestFinished(response: .OK(.notUpdated), result: nil)
		}
	}
	
	func submit(_ entity: [T], requestMethod: RequestMethod) {
		body = entity
		self.requestMethod = requestMethod
		self.request(force: true)
	}
	
	private func executeRequest() {
		
		if path == "" {
			let error = NSError(domain: "No object id found for: \(requesterId)", code: 0, userInfo: nil)
			print(error)
			requestFinished(response: .error(nil, error as Error), result: nil)
			return
		}
		
		let url = ChurchBeamConfiguration.environment.endpoint + path
		
		if requestMethod == .get {
			requestGet(url:  url, parameters: params, success: { (response, result) in
				
				self.requestFinished(response: .OK(.updated), result: result)
				
			}, failure: { (error, response, result) in
				let restError = error ?? (result != nil ? NSError(domain: result!.errorMessage, code: 0, userInfo: nil) : nil)
				self.requestFinished(response: .error(response, restError), result: nil)
			}, queue: Queues.background)
		} else {
			requestSend(url: url, object: body, parameters: params, range: range, success: { (resonpse, result) in
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
	
	func requesterDidStart() {
	}
	
	func requestFinished(response: ResponseType, result: [T]?) {
		body = nil
		switch response {
		case .OK(let action):
			print(requesterId + ": \(action)")
			if action == .updated {
				minRefreshDate = requestReloadTime.date
			}
		default: break
		}
		Queues.main.async {
			self.observers.forEach({ $0.requestDidFinish(requesterID: self.requesterId, response: response, result: result as AnyObject) })
		}
	}
	
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		if requesterDependencies.map({ $0.isFinished }).count == requesterDependencies.count {
			executeRequest()
		}
	}
	
	func mapDataToJSON(_ data : Data) throws -> [[String: Any]]? {
		let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
		return json
	}
	
	
	
	
	func requestGet(_ method: RequestMethod = .get, url: String, parameters: [String: Any]?, range: CountableRange<Int>? = nil, success: @escaping (_ response: HTTPURLResponse?, _ result: [T]?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ object: RestError?) -> Void, queue: DispatchQueue) {
		
		super.dispatchRequest(method, url: url, inputBody: nil, parameters: parameters, range: range, success: {  (response, data) -> Void in
			
			// delete all the old that we have based on new with their id's
			
			let entities: [T]? = super.decode(data: data)
			
			if self.body?.first is User? {
				
			}
			
			if let old = entities, old.count > 0 {
				mocBackground.perform({

					if let oldEntity = old as? [Entity] {
						print("old items to delete: \(oldEntity.count)")
						oldEntity.forEach({
							CoreEntity.managedObjectContext = mocBackground
							CoreEntity.predicates.append("id", equals: $0.id)
							let ent = CoreEntity.getEntities().filter({ $0.updatedAt != nil })
							if ent.count > 1 {
								let oldEntities = ent.sorted(by: { (($0.updatedAt ?? NSDate()) as Date) < (($1.updatedAt ?? NSDate()) as Date) })
								if let objectId = oldEntities.first?.objectID, (entities?.contains(where: { $0.objectID == objectId }) ?? false) {
									oldEntities.last?.deleteBackground(false)
								} else {
									oldEntities.first?.deleteBackground(false)
								}
							}
						})
					}
					mocBackground.performAndWait {
						do {
							try mocBackground.save()
							try moc.save()
						} catch {
							print(error)
						}
						
						success(response, entities)
						
					}
					
				})
			} else {
				success(response, entities)
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

		inputBody?.printToJson()
		
		super.dispatchRequest(self.requestMethod, url: url, inputBody: inputBody, parameters: parameters, range: range, success: {  (response, data) -> Void in
			
			data?.printToJson()
			
			// delete all the old that we have based on new with their id's
			
			if let entities = self.body as?[Entity] {
				entities.forEach({ $0.delete(false) })
				do {
					try moc.save()
				} catch {
					print(error)
				}
			}
			
			mocBackground.perform({
				
				let deleteOld: [T]? = super.decode(data: data)

				if let old = deleteOld, old.count > 0 {
					if let oldEntity = old as? [Entity] {
						print("old items to delete: \(oldEntity.count)")
						oldEntity.forEach({
							CoreEntity.managedObjectContext = mocBackground
							CoreEntity.predicates.append("id", equals: $0.id)
							let ent = CoreEntity.getEntities().filter({ $0.updatedAt != nil })
							if ent.count > 1 {
								let oldEntities = ent.sorted(by: { (($0.updatedAt ?? NSDate()) as Date) < (($1.updatedAt ?? NSDate()) as Date) })
								oldEntities.first?.deleteBackground(false)
							}
						})
					}
					mocBackground.performAndWait {
						do {
							try mocBackground.save()
							try moc.save()
						} catch {
							print(error)
						}
						
						success(response, old)
						
					}
				} else {
					
					var result : [T]? = nil
					if let data = data {
						do {
							result = try JSONDecoder().decode([T].self, from: data)
						} catch (let error){
							print("Error \(error)")
						}
					}
					
					success(response, result)
				}
			
			})
			
		}, failure: {   (error, response, data) -> Void in
			
			let restError: RestError? = super.decodeSingle(data: data)
			
			failure(error, response, restError)
			
		}, queue: queue)
	}
	
	
}

protocol RequesterType {
	
	var isFinished: Bool { get }
	var requesterId: String { get }
	var observers: [RequestObserver] { get set }
	
	func addObserver(_ controller: RequestObserver)
	func request(force: Bool)
	
}

protocol RequestObserver {
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

enum RequesterReloadTime {
	case immidiate
	case seconds
	case minute
	case hour
	case day
	case week
	case month
	
	var date: Date {
		switch self {
		case .immidiate: return Date().dateByAddingSeconds(3)
		case .seconds: return Date().dateByAddingSeconds(10)
		case .minute: return Date().dateByAddingMinutes(1)
		case .hour: return Date().dateByAddingHours(1)
		case .day: return Date().dateByAddingDays(1)
		case .week: return Date().dateByAddingWeeks(1)
		case .month: return Date().dateByAddingWeeks(4)
		}
	}
}
