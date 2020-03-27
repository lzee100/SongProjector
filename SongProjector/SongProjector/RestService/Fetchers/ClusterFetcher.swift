//
//  ClusterFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let ClusterFetcher = CstrFetcher()

class CstrFetcher: Requester<VCluster> {
	
	override var requesterId: String {
		return "ClusterFetcher"
	}
	
	override var path: String {
		return "clusters"
	}
	
	override var dependencies: [RequesterDependency] {
		return [ThemeFetcher, TagFetcher]
	}
	
	override var params: [String : Any] {
		var params = super.params
//		if let date = VCluster.list(sortOn: "updatedAt", ascending: false).first?.updatedAt {
//			params["updatedsince"] = GlobalDateFormatter.localToUTC(date: date as Date)
//		}
		return params
	}
	
	func fetch() {
		guard isSuperRequesterTotalFinished else {
			print("cluster blocked")
			return
			
		}
		requestMethod = .get
		request(isSuperRequester: false)
	}
	
	override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VCluster], completion: @escaping ((Requester<VCluster>.AdditionalProcessResult) -> Void)) {
		
		let downloadObjects = entities.flatMap({ $0.downloadMusicObjects }).unique
		
		AmazonTransfer.startTransfer(uploads: [], downloads: downloadObjects) { (result) in
			switch result {
			case .failed(error: let error):
				completion(.failed(error: error))
			case .success(result: _):
				
				for sheet in entities.flatMap({ $0.hasSheets }) {
					if let sheetTheme = sheet.hasTheme, let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == sheetTheme.imagePathAWS }) {
						sheet.hasTheme?.imagePath = downloadObject.localURL?.absoluteString
						sheet.hasTheme?.imagePathThumbnail = downloadObject.localThumbURL?.absoluteString
					}
					if let sheet = sheet as? VSheetPastors {
						if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == sheet.imagePathAWS }) {
							sheet.imagePath = downloadObject.localURL?.absoluteString
							sheet.thumbnailPath = downloadObject.localThumbURL?.absoluteString
						}
					} else if let sheet = sheet as? VSheetTitleImage {
						if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == sheet.imagePathAWS }) {
							sheet.imagePath = downloadObject.localURL?.absoluteString
							sheet.thumbnailPath = downloadObject.localThumbURL?.absoluteString
						}
					}
				}
				
				completion(.succes(result: entities))
				
			}
		}
		
	}
}
