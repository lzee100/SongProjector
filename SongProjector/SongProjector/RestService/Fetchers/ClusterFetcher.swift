//
//  ClusterFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let ClusterFetcher = CstrFetcher()

class CstrFetcher: Requester<Cluster, SubmittedID> {
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}
	
	override var requesterId: String {
		return "ClusterFetcher"
	}
	
	override var path: String {
		return "clusters"
	}
	
	override var requesterDependencies: [RequesterType] {
		return [TagFetcher]
	}
	
	override var coreDataManager: CoreDataManager<Cluster> {
		return CoreCluster
	}
	
	override var params: [String : Any] {
		CoreCluster.setSortDescriptor(attributeName: "updatedAt", ascending: false)
		let tag = CoreCluster.getEntities().first
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
	
//	override func proces(entities: [Cluster]) {
//		entities.forEach({
//			if let tagID = $0.hasTag?.id {
//				CoreTag.managedObjectContext = mocBackground
//				let tag = CoreTag.getEntitieWith(id: tagID)
//				let deleteTag = $0.hasTag
//				deleteTag?.deleteBackground(false)
//				$0.hasTag = tag
//				tag?.addToHasCluster($0)
//			}
//		})
//	}
	
//	override func merge(entity: Cluster, into: Cluster) {
//		let sheets = entity.hasSheets?.allObjects as? [Sheet]
//		let tag = entity.hasTag
//		entity.mergeSelfInto(cluster: into)
//		if let sheets = sheets, let intoSheets = into.hasSheets?.allObjects as? [Sheet] {
//			sheets.forEach({ sheet in
//				if let into = intoSheets.first(where: { $0.id == sheet.id }) {
//					sheet.mergeSelfInto(sheet: into)
//					if let tag = sheet.hasTag, let intoTag = into.hasTag {
//						tag.mergeSelfInto(tag: intoTag, sheetType: sheet.type)
//					}
//				}
//			})
//		}
//		if let clusterTag = tag, let intoTag = into.hasTag {
//			clusterTag.mergeSelfInto(tag: intoTag, sheetType: .SheetTitleContent)
//		}
//		entity.deleteBackground(false)
//		sheets?.forEach({ $0.deleteBackground(false) })
//		tag?.deleteBackground(false)
//
//	}
	
	
}
