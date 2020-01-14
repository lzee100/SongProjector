//
//  ContractFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let ContractFetcher: CntractFetcher = {
	return CntractFetcher()
}()

class CntractFetcher: Requester<VContract> {
	
	override var requesterId: String {
		return "ContractFetcher"
	}

	override var path: String {
		return "contracts"
	}

	override var params: [String : Any] {
		return userParams
	}

	private var userParams: [String : Any] = [:]

	func fetch(locale: String) {
		userParams = ["locale": locale]
		requestMethod = .get
		request(isSuperRequester: false)
	}

}
