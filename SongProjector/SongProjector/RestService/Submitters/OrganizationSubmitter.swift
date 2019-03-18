//
//  OrganizationSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let OrganizationSubmitter: OnizationSubmitter = {
	return OnizationSubmitter()
}()

class OnizationSubmitter: Requester<Organization> {
	
	override var requesterId: String {
		return "OrganizationSubmitter"
	}
	
	override var path: String {
		return "organizations"
	}
	
	override var coreDataManager: CoreDataManager<Organization> {
		return CoreOrganization
	}
	
}
