//
//  UploadSecretFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

let UploadSecretFetcher: UloadSecretFetcher = {
	return UloadSecretFetcher()
}()


class UloadSecretFetcher: Requester<VUploadSecret> {
	
	override var requesterId: String {
		return "UploadSecretFetcher"
	}
	
	override var path: String {
		return "secret"
	}
	
	var secret = ""
	
	override var params: [String : Any] {
		var params = super.params
		params["secret"] = secret
		return params
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else { return }
		requestMethod = .get
		request(isSuperRequester: false)
	}

	
}

class VUploadSecret: VEntity {
	
}


