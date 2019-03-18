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


class UerFetcher: Requester<User> {
	
	private var fetchMe = false
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterDependencies: [RequesterType] {
		return [RoleFetcher]
	}
	
	override var requesterId: String {
		return "UserFetcher"
	}
	
	override var path: String {
		return "users"
	}
	
	override var suffix: String {
		guard let userId = CoreUser.getEntities().filter({ $0.isMe }).first?.id else {
			return ""
		}
		if fetchMe {
			fetchMe = false
			return "/\(userId)"
		}
		return ""
	}
	
	override var coreDataManager: CoreDataManager<User> {
		return CoreUser
	}
	
	func fetchMe(force: Bool) {
		fetchMe = true
		requestMethod = .get
		request(force: force)
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
	
}
