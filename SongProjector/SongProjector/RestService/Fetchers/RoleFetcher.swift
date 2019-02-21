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


class RleFetcher: Requester<Role> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterDependencies: [RequesterType] {
		return [OrganizationFetcher]
	}
	
	override var requesterId: String {
		return "RoleFetcher"
	}
	
	override var path: String {
		return "roles"
	}
	
	override var coreDataManager: CoreDataManager<Role> {
		return CoreRole
	}
	
	override var params: [String : Any] {
		let roleId = CoreRole.getEntities().first?.id
		var params = super.params
		if let roleId = roleId {
			params["roleId"] = "\(roleId)"
		}
		return params
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
	
}
