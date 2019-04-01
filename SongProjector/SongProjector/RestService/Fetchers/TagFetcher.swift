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


class TgFetcher: Requester<Tag> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "TagFetcher"
	}
	
	override var path: String {
		return "tags"
	}
	
	override var coreDataManager: CoreDataManager<Tag> {
		return CoreTag
	}
	
	override var params: [String : Any] {
		coreDataManager.setSortDescriptor(attributeName: "updatedAt", ascending: false)
		let tag = coreDataManager.getEntities().first
		var params = super.params
		if let date = tag?.updatedAt {
			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
		}
		return params
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
	
}
