//
//  OrganizationFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let OrganizationFetcher: OganizationFetcher = {
	return OganizationFetcher()
}()


class OganizationFetcher: Requester<VOrganization> {
	
	override var requesterId: String {
		return "OrganizationFetcher"
	}
	
	override var path: String {
		return "organizations"
	}
	
	override var params: [String : Any] {
		let orgId = VOrganization.list().first?.id
		var params = super.params
		if let orgId = orgId {
			params["organizationId"] = "\(orgId)"
		} else {
			let user = VUser.list().first
			if let userId = user?.id, let appId = user?.appInstallToken {
				params["userId"] = "\(userId)"
				params["appId"] = "\(appId)"
			}
		}
		return params
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else { return }
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
	
}
