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


class SngServiceSettingsFetcher: Requester<SongServiceSettings> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "SongServiceSettingsFetcher"
	}
	
	override var path: String {
		return "songservicesettings"
	}
	
	override var coreDataManager: CoreDataManager<SongServiceSettings> {
		return CoreSongServiceSettings
	}
	
	override var params: [String : Any] {
		coreDataManager.setSortDescriptor(attributeName: "updatedAt", ascending: false)
		let songservicesettings = coreDataManager.getEntities().first
		var params = super.params
//		if let date = songservicesettings?.updatedAt {
//			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
//		}
		if let id = songservicesettings?.id {
			params["songServiceId"] = id
		}
		return params
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
	
}
