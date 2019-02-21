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


class OganizationFetcher: Requester<Organization> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "OrganizationFetcher"
	}
	
	override var path: String {
		return "organizations"
	}
	
	override var coreDataManager: CoreDataManager<Organization> {
		return CoreOrganization
	}
	
	override var params: [String : Any] {
		let orgId = CoreOrganization.getEntities().first?.id
		var params = super.params
		if let orgId = orgId {
			params["organizationId"] = "\(orgId)"
		}
		return params
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
	
}
