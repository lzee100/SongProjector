//
//  TagFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let TagFetcher: TgFetcher = {
	return TgFetcher()
}()


class TgFetcher: Requester<VTag> {
	
	override var requesterId: String {
		return "TagFetcher"
	}
	
	override var path: String {
		return "tags"
	}
	
	override var params: [String : Any] {
		let tag = VTag.list(sortOn: "updatedAt", ascending: false).first
		var params = super.params
		if let date = tag?.updatedAt {
			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
		}
		return params
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else { return }
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
	
}
