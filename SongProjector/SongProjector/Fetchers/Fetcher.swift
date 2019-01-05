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

class Fetcher: FetcherType {
	
	
	var fetcherDependencies: [FetcherType] = []
	
	var path: String = ""
	
	var updateTime: FetcherReloadTime = .hour
	
	func needsUpdate() -> Bool {
		<#code#>
	}
	


	struct Constants {
		static let iddinkId = "logoLastUpdatedIddink"
		static let organizationId = "logoLastUpdateOrganization"
	}

	var observers: [FetcherObserver] = []

	var url: URL = URL(fileURLWithPath: "")
	var needsUpdating : Bool {
		return needsRefresh()
	}

	func addObserver(_ controller: FetcherObserver) {
		observers.append(controller)
	}

	func fetch(_ force: Bool) {
		
		BaseRestService.req
		DispatchQueue.global(qos: .background).async {
			self.fetchDependencies(self.fetcherDependencies.compactMap({ $0 as? Foundation.Operation }))
			if self.needsUpdating || force {
				self.downloadImage(url: self.url)
			} else {
				self.fetchFinished(result: .OK(.notUpdated))
			}
		}
	}

	func fetchFinished(result: ResultTypes) {
		observers.forEach { $0.FetcherDidFinish(result: result) }
	}
	
	private func fetchDependencies(_ dependencies: [Foundation.Operation]) {
		let operationQueue = OperationQueue()
		operationQueue.addOperations(dependencies, waitUntilFinished: true)
	}
	
	

//	private func downloadImage(url: URL) {
//		observers.forEach { $0.logoFetcherDidStart() }
//
//		getDataFromUrl(url: url) { data, response, error in
//			if error != nil {
//				DispatchQueue.main.async {
//					self.observers.forEach { $0.logoFetcherDidFinish(result: ResultTypes.error) }
//				}
//			} else if let data = data {
//				DispatchQueue.main.async {
//					if let image = UIImage(data: data) {
//						self.saveImageLocaly(image: image)
//						self.observers.forEach { $0.logoFetcherDidFinish(result: .OK) }
//					} else {
//						self.observers.forEach { $0.logoFetcherDidFinish(result: .imageError) }
//					}
//				}
//			} else {
//				self.observers.forEach { $0.logoFetcherDidFinish(result: .error) }
//			}
//		}
//	}
//
//	private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//		URLSession.shared.dataTask(with: url) { data, response, error in
//			completion(data, response, error)
//			}.resume()
//	}

	func needsRefresh() -> Bool {
		return true
	}

}


