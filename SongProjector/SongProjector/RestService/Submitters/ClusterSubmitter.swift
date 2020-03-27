//
//  ClusterSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

let ClusterSubmitter = CstrSubmitter()

class CstrSubmitter: Requester<VCluster> {
	
	
	override var requesterId: String {
		return "ClusterSubmitter"
	}
	
	override var path: String {
		return "clusters"
	}
	
	override func createHeaderParameters() -> [String : String] {
		var headerParams = super.createHeaderParameters()
		if let secret = UserDefaults.standard.string(forKey: secretKey) {
			headerParams["secret"] = secret
		}
		return headerParams
	}
	
	override func prepareForSend(body: [VCluster], completion: @escaping ((AdditionalProcessResult) -> Void)) {
		let uploads = body.flatMap({ $0.uploadImagesObjecs }) + body.flatMap({ $0.uploadMusicObjects })
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
	
	override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VCluster], completion: @escaping ((AdditionalProcessResult) -> Void)) {
		// remove root cluster
		for cluster in entities {
			CoreCluster.managedObjectContext = context
			if let root = cluster.root, let rootCluster = CoreCluster.getEntitieWith(id: root) {
				rootCluster.hasSheetsArray.forEach({
					if let theme = $0.hasTheme {
						context.delete(theme)
					}
					context.delete($0)
				})
				context.delete(rootCluster)
				do {
					try context.save()
					try moc.save()
				} catch let err {
					print(err)
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
