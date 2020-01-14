//
//  UserFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let UserFetcher = UerFetcher()


class UerFetcher: Requester<VUser> {
	
	private var fetchMe = false

	override var dependencies: [RequesterDependency] {
		return [RoleFetcher]
	}
	
	override var requesterId: String {
		return "UserFetcher"
	}
	
	override var path: String {
		return "users"
	}
	
	override var suffix: String {
		guard let userId = VUser.list().first(where: { $0.isMe })?.id else {
			return ""
		}
		if fetchMe {
			fetchMe = false
			return "/\(userId)"
		}
		return ""
	}
	
	func fetchMe(force: Bool) {
		guard isSuperRequesterTotalFinished else { return }
		fetchMe = true
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else { return }
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
	
}
