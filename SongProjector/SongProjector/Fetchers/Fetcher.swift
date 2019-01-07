//
//  Fetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

protocol FetcherType {

	var observers: [FetcherObserver] { get set }
	var fetcherDependencies: [FetcherType] { get set }
	var path: String { get set }
	var updateTime: FetcherReloadTime { get set }
	
	func addObserver(_ controller: FetcherObserver)
	func fetch(_ force: Bool)
	func needsUpdate() -> Bool

	func fetchFinished(result: ResultTypes)
	
}

protocol FetcherObserver {
	func FetcherDidStart()
	func FetcherDidFinish(result: ResultTypes)
}

enum ResultOkType {
	case notUpdated
	case updated
}

enum ResultTypes {
	case OK(ResultOkType)
	case error(String)
}

enum FetcherReloadTime {
	case immidiate
	case minute
	case hour
	case day
	case week
	case month
}

let OrganizationLogoFetcher = Fetcher()
let IddinkLogoFetcher = Fetcher()

class Fetcher<T: Decodable>: BaseRS, FetcherType {
	
	var fetcherDependencies: [FetcherType] = []
	
	var path: String = ""
	
	var updateTime: FetcherReloadTime = .hour
	
	func needsUpdate() -> Bool {
		return true
	}

	var observers: [FetcherObserver] = []
	
	var params: [String: Any] = [:]
	var range: CountableRange = CountableRange(0...200)

	var url: String = ""
	var needsUpdating : Bool {
		return needsRefresh()
	}


	func addObserver(_ controller: FetcherObserver) {
		observers.append(controller)
	}

	func fetch(_ force: Bool) {
		
		if needsUpdate() || force {
			getEntities(success: { (result, response) in
				
			}) { (error,response,decodedError) in
				print(error ?? "")
			}
		} else {
			
		}
	}
	
	func getEntities(success: @escaping (_ response: HTTPURLResponse?, _ result: [T]?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ result: VTheme?) -> Void){
		super.requestGet(RequestMethod.get, url: url, parameters: params, success: success, failure: failure, queue: Queues.background)
	}

	func fetchFinished(result: ResultTypes) {
		observers.forEach { $0.FetcherDidFinish(result: result) }
	}
	
	private func fetchDependencies(_ dependencies: [Foundation.Operation]) {
		let operationQueue = OperationQueue()
		operationQueue.addOperations(dependencies, waitUntilFinished: true)
	}

	func needsRefresh() -> Bool {
		return true
	}

}


