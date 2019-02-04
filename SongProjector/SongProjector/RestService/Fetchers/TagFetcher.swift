//
//  ThemeFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let TagFetcher = TgFetcher()


class TgFetcher: Requester<Tag, SubmittedID> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "TagFetcher"
	}
	
	override var path: String {
		return "themes"
	}
	
	override var coreDataManager: CoreDataManager<Tag> {
		return CoreTag
	}
	
	override var params: [String : Any] {
		CoreTag.setSortDescriptor(attributeName: "updatedAt", ascending: false)
		let tag = CoreTag.getEntities().first
		var params = super.params
		if let date = tag?.updatedAt {
			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
		}
		return params
	}
	
	override func requesterDidStart() {
		super.requesterDidStart()
	}
	
	func fetch(force: Bool) {
		requestMethod = .get
		request(force: force)
	}
	
	override func merge(entity: Tag, into: Tag) {
		entity.mergeSelfInto(tag: into, sheetType: .SheetTitleContent)
		entity.deleteBackground(false)
	}
	
	override func saveLocal(entities: [Tag]?) {

		super.saveLocal(entities: entities)
		
	}
	
	
}
