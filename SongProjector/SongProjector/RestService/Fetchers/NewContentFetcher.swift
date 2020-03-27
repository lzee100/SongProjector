//
//  NewContentFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

//import Foundation
//
//let NewContentFetcher: NwContentFetcher = {
//	return NwContentFetcher()
//}()
//
//
//class NwContentFetcher: Requester<VCluster> {
//
//	override var requesterId: String {
//		return "NewContentFetcher"
//	}
//
//	override var path: String {
//		return "newContent"
//	}
//
//	override var params: [String : Any] {
//		let params = super.params
//		return params
//	}
//
//	func fetch() {
//		guard isSuperRequesterTotalFinished else { return }
//		requestMethod = .get
//		request(isSuperRequester: false)
//	}
//
//	override func additionalProcessing(_ entities: [VCluster]?, completion: (([VCluster]?) -> Void)) {
//		// download content for clusters from amazon
//		completion(entities)
//	}
//
//
//}
