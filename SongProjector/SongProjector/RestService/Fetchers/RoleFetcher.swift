//
//  RoleFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let RoleFetcher: RleFetcher = {
	return RleFetcher()
}()


class RleFetcher: Requester<VRole> {
	
	override var dependencies: [RequesterDependency] {
		return [OrganizationFetcher]
	}
	override var requesterId: String {
		return "RoleFetcher"
	}
	
	override var path: String {
		return "roles"
	}
	
	override var params: [String : Any] {
		let roleId = CoreUser.getEntities().first?.roleId
		var params = super.params
		if let roleId = roleId {
			params["roleId"] = "\(roleId)"
		}
		return params
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else { return }
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
	
}
