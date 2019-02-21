//
//  InitFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


let InitFetcher: ItFetcher = {
	return ItFetcher()
}()


class ItFetcher: Requester<User> {
	
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "InitFetcher"
	}
	
	override var path: String {
		return "userinit"
	}
	
	override var coreDataManager: CoreDataManager<User> {
		return CoreUser
	}
	
	override var params: [String : Any] {
		return userParams
	}
	
	private var userParams: [String : Any] = [:]
	
	func request(userTokenAndAppToken: UserTokenAndAppInstallToken, method: RequestMethod) {
		userParams = ["userToken": userTokenAndAppToken.userToken, "appInstallToken": userTokenAndAppToken.appInstallToken]
		requestMethod = method
		request(force: true)
	}
	
}


struct UserTokenAndAppInstallToken: Encodable {
	
	let userToken: String
	let appInstallToken: String
	
	enum CodingKey: String {
		case userToken
		case appInstallToken
	}
	
}
