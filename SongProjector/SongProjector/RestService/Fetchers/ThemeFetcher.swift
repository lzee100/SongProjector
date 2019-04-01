//
//  ThemeFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let ThemeFetcher: TmeFetcher = {
	return TmeFetcher()
}()


class TmeFetcher: Requester<Theme> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "ThemeFetcher"
	}
	
	override var path: String {
		return "themes"
	}
	
	override var coreDataManager: CoreDataManager<Theme> {
		return CoreTheme
	}
	
	override var params: [String : Any] {
		CoreTheme.setSortDescriptor(attributeName: "updatedAt", ascending: false)
		let theme = CoreTheme.getEntities().first
		var params = super.params
		if let date = theme?.updatedAt {
			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
		}
		return params
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}

	
}


