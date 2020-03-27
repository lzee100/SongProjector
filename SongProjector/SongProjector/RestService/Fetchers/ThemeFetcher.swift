//
//  ThemeFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

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
	
	override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VTheme], completion: @escaping ((Requester<VTheme>.AdditionalProcessResult) -> Void)) {
		
		let downloadObjects = entities.flatMap({ $0.downloadImagesObjects })
		AmazonTransfer.startTransfer(uploads: [], downloads: downloadObjects, completion: { result in
			switch result {
			case .failed(error: let error):
				completion(.failed(error: error))
			case .success(result: let downloadObjects):
				entities.forEach({ $0.setDownloadValues(downloadObjects as! [DownloadObject]) })
				completion(.succes(result: entities))
			}
		})
		
	}


	
}


