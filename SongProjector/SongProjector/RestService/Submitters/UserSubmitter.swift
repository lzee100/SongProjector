//
//  UserSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let UserSubmitter: UerSubmitter = {
	return UerSubmitter()
}()

class UerSubmitter: Requester<User> {
	
	override var requesterId: String {
		return "UserSubmitter"
	}
	
	override var path: String {
		return "users"
	}
	
	override var coreDataManager: CoreDataManager<User> {
		return CoreUser
	}
	
}
