//
//  InitSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


let InitSubmitter: ItSubmitter = {
	return ItSubmitter()
}()


class ItSubmitter: Requester<VUser> {
	
	override var requesterId: String {
		return "InitFetcher"
	}
	
	override var path: String {
		return "userinit"
	}
	
	override var params: [String : Any] {
		return userParams
	}
	
	private var userParams: [String : Any] = [:]
	
	func request(userTokenAndAppToken: UserTokenAndAppInstallToken, method: RequestMethod, isNewInstall: Bool) {
		userParams = ["userToken": userTokenAndAppToken.userToken, "appInstallToken": userTokenAndAppToken.appInstallToken, "isNewInstall": isNewInstall]
		requestMethod = method
		request(isSuperRequester: false)
	}
	
	func submitUserInit(_ userInitInfo: UserInitInfo, success: @escaping (_ response: HTTPURLResponse?, _ result: [VUser]?) -> Void, failure: @escaping (_ error: NSError?, _ response: HTTPURLResponse?, _ object: RestError?) -> Void) {
		requestMethod = .post
		let url = ChurchBeamConfiguration.environment.endpoint + path
		super.requestSend(url: url, object: [userInitInfo], parameters: nil, success: success, failure: failure, queue: Queues.main)
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

struct UserInitInfo: Encodable {
	
	let organizationTitle: String
	let phoneNumber: String
	let userName: String
	let appInstallToken: String
	let userToken: String
	let contractId: Int64
	let hasApplePay: Bool
	
	
	enum CodingKeysUserInitInfo: String, CodingKey
	{
		case organizationTitle
		case phoneNumber
		case userName
		case appInstallToken
		case userToken
		case contractId
		case hasApplePay
	}
	
	
	
	// MARK: - Encodable
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysUserInitInfo.self)
		try container.encode(organizationTitle, forKey: .organizationTitle)
		try container.encode(phoneNumber, forKey: .phoneNumber)
		try container.encode(userName, forKey: .userName)
		try container.encode(appInstallToken, forKey: .appInstallToken)
		try container.encode(userToken, forKey: .userToken)
		try container.encode(contractId, forKey: .contractId)
		try container.encode(hasApplePay, forKey: .hasApplePay)
	}
	
}
