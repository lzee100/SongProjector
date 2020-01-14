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


class TmeFetcher: Requester<VTheme> {
	
	override var requesterId: String {
		return "ThemeFetcher"
	}
	
	override var path: String {
		return "themes"
	}
	
	override var params: [String : Any] {
		let theme = VTheme.list(sortOn: "updatedAt", ascending: false).first
		var params = super.params
		if let date = theme?.updatedAt {
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


