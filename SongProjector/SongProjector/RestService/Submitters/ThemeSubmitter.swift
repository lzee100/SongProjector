//
//  ThemeSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

struct SubmittedID: Codable {
	let id: Int64
	
	private enum CodingKeys: String, CodingKey {
		case id
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int64.self, forKey: .id)
	}
	
}

let ThemeSubmitter: TmSubmitter = {
	return TmSubmitter()
}()

class TmSubmitter: Requester<VTheme> {
	
	
	override var requesterId: String {
		return "ThemeSubmitter"
	}
	
	override var path: String {
		return "themes"
	}
	
	override func submit(_ entity: [VTheme], requestMethod: RequestMethod) {
		if UserDefaults.standard.object(forKey: secretKey) != nil {
			entity.forEach({ $0.isUniversal = true })
			super.submit(entity, requestMethod: requestMethod)
		} else {
			entity.forEach({ $0.isUniversal = false })
			super.submit(entity, requestMethod: requestMethod)
		}
	}
	
	override func prepareForSend(body: [VTheme], completion: @escaping ((AdditionalProcessResult) -> Void)) {
		let uploads = body.flatMap({ $0.uploadImagesObjecs })
		AmazonTransfer.startTransfer(uploads: uploads, downloads: []) { (result) in
			switch result {
			case .failed(error: let error):
				completion(.failed(error: error))
			case .success(result: let uploadObjects):
				body.forEach({ $0.setUploadValues(uploadObjects as! [UploadObject]) })
				completion(.succes(result: body))
			}
		}
	}
	
	override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VTheme], completion: @escaping ((Requester<VTheme>.AdditionalProcessResult) -> Void)) {
		for theme in entities {
			for bodyTheme in body ?? [] {
				if bodyTheme.imagePathAWS == theme.imagePathAWS {
					theme.imagePath = bodyTheme.imagePath
					theme.imagePathThumbnail = bodyTheme.imagePathThumbnail
				}
			}
		}
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
