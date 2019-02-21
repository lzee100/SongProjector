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
	
	override var coreDataManager: CoreDataManager<User> {
		return CoreUser
	}
	
	override var params: [String : Any] {
		let userId = CoreUser.getEntities().first?.id
		var params = super.params
		if let userId = userId {
			params["userId"] = "\(userId)"
		}
		return params
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
	
}
