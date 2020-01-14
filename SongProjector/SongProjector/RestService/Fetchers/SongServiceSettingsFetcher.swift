//
//  SongServiceSettingsFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let SongServiceSettingsFetcher: SngServiceSettingsFetcher = {
	return SngServiceSettingsFetcher()
}()


class SngServiceSettingsFetcher: Requester<VSongServiceSettings> {
	
	override var requesterId: String {
		return "SongServiceSettingsFetcher"
	}
	
	override var path: String {
		return "songservicesettings"
	}
	
	override var params: [String : Any] {
		var params = super.params
		if let id = VSongServiceSettings.list(sortOn: "updatedAt", ascending: false).first?.id {
			params["songServiceId"] = id
		}
		return params
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else { return }
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
	
}
