//
//  NewContentFetchJob.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

//
//let NewContentFetchJob = NwContentFetchJob()
//
//class NwContentFetchJob: NSObject {
//
//
//	override init() {
//		super.init()
//		NewContentFetcher.addObserver(self)
//	}
//
//	func getNewContent() {
//		if VUser.list().first != nil, UserDefaults.standard.object(forKey: secretKey) == nil {
//			NewContentFetcher.fetch()
//		}
//	}
//
//
//}
//
//extension NwContentFetchJob: RequestObserver {
//	var requesterId: String {
//		return "NewContentFetchJob"
//	}
//
//	func requesterDidStart() {
//	}
//
//	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
//		if let result = result as? [VCluster], result.count > 0 {
//			NotificationCenter.default.post(name: NotificationNames.newContentAvailable, object: nil)
//			NewContentFetchJob.getNewContent()
//		}
//	}
//}
