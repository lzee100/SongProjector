//
//  UserSpecialFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 20/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

struct UserTokenAndAppRegistrationID: Encodable {
	
	let userToken: String
	let appRegistrationId: String
	
	enum CodingKey: String {
		case userToken
		case appRegistrationId
	}
	
}


class UserInitFetcher: BaseRS {
	
	func getUserFor(_ usertokenRegId: UserTokenAndAppRegistrationID, success: @escaping ((User?) -> Void), failure: @escaping (NSError?, HTTPURLResponse?, Data?) -> Void) {
		
		let url = ChurchBeamConfiguration.environment.endpoint + "userinit"
		var data: Data? = nil
		do {
			data = try JSONEncoder().encode(usertokenRegId)
		}
		catch {
			failure(error as NSError, nil, nil)
		}
		
		
		dispatchRequest(.get, url: url, inputBody: data, parameters: nil, range: nil, success: { (response, result) in
			
			if let result = result {
				var user: User? = nil
				do {
					user = try JSONDecoder().decode(User.self, from: result)
				} catch {
					failure(error as NSError, nil, nil)
				}
				success(user)
			} else {
				success(nil)
			}
		}, failure: failure, queue: Queues.background)
		
	}
	
	
}
