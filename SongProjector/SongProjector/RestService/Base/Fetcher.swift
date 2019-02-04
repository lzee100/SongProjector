////
////  Requester.swift
////  SongProjector
////
////  Created by Leo van der Zee on 24-01-18.
////  Copyright © 2018 iozee. All rights reserved.
////
//import Foundation
//
//
//class Fetcher<T: Decodable>: Requester<T> {
//
//
//	// MARK: - Properties
//
//	override var requesterId: String {
//		return "Fetcher"
//	}
//
//	override var requestReloadTime: RequesterReloadTime {
//		return .minute
//	}
//
//
//	var updateTime: RequesterReloadTime = .minute
//
//	private var needsUpdating : Bool {
//		return minRefreshDate.isBefore(Date())
//	}
//
//
//	// MARK: - Functions
//
//	override func executeRequest() {
//
////		super.getEntities(success: { (response, result) in
////			Queues.main.async {
////				self.minRefreshDate = self.fetchReloadTime.date
////				self.saveLocal(entities: result ?? [])
////			}
////		}) { (error,response,decodedError) in
////			self.fetchFinished(result: .error(response, error))
////		}
//	}
//
//	func fetchFinished(result: ResultTypes) {
//		Queues.main.async {
//			self.observers.forEach { $0.requesterDidFinish(result: result) }
//		}
//	}
//
//
//
//	// MARK: Private Functions
//
////	private func getEntities(success: @escaping (_ response: HTTPURLResponse?, _ result: [T]?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ result: T?) -> Void){
////		let url = ChurchBeamConfiguration.environment.endpoint + path
////		super.requestGet(RequestMethod.get, url: url, parameters: params, success: success, failure: failure, queue: Queues.background)
////	}
//
//}
