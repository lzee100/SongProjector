//
//  FileDownloader.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/02/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore

enum TransferError: Error {
	case noFileFoundForUpload
	case noResultFromAWS
	case noAWSURLasResponse
	case noWritePath
	case awsError(Error)
	case writeError(Error)
	case fileTypeFromAmazonNotRicognized
}

typealias progressBlock = (_ bytesTransferred: Int?, _ total: Int?) -> Void
typealias completionBlock = (_ response: Any?, _ error: Error?) -> Void

class FileDownloadOperation: AsynchronousOperation, TransferOperation {
	
    let bucketName = "churchbeam-europe-central"

	let downloadObject: DownloadObject
	let delegate: TransferChange?
	var progress: Double = 0
	var error: Error?
	
	init(downloadObject: DownloadObject, delegate: TransferChange) {
		self.downloadObject = downloadObject
		self.delegate = delegate
	}
	
	init(downloadObject: DownloadObject) {
		self.downloadObject = downloadObject
		self.delegate = nil
	}

	
	override func main() {
		super.main()
		
		prepare {
			self.startDownloading()
		}
		
	}
	
	
	func prepare(completion: (() -> Void)) {
		
		// url to data???
		
		completion()
	}
	
	func startDownloading() {
		downloadfile(downloadObject: downloadObject, progress: { (transferred, total) in
			
		}) { (result, error) in
			if let error = error {
				self.error = error
				self.didFail()
			} else {
				self.didFinish()
			}
		}
	}
	
	private func downloadfile(downloadObject: DownloadObject, progress: progressBlock?, completion: completionBlock?) {
        // Upload progress block
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, awsProgress) in
            guard let downloadProgress = progress else { return }
            DispatchQueue.main.async {
				print("proces: \(awsProgress.fileCompletedCount), total: \(awsProgress.fileTotalCount)")
                downloadProgress(awsProgress.fileCompletedCount, awsProgress.fileTotalCount)
            }
        }
        // Completion block
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (downloadTask, url, data, error) -> Void in
			if error == nil {
				switch TransferType(fileExtension: downloadObject.remoteURL.pathExtension) {
				case .none:
					if let completionBlock = completion {
						completionBlock(nil, TransferError.fileTypeFromAmazonNotRicognized)
					}
				case .jpeg, .jpg:
					
					if let url = FileManager.urlFor(fileName: downloadObject.fileName), let image = UIImage.get(imagePath: url.absoluteString) {
						print("has image")
					} else {
						print("no image")
						completionBlock(downloadObject, nil)
					}
				case .m4a, .mp3:
					self.processImage(data: data, completion: completion)
				}
			} else {
				if let completionBlock = completion {
					completionBlock(nil, error)
				}
			}
        }
		
		
        // Start uploading using AWSS3TransferUtility
        let awsTransferUtility = AWSS3TransferUtility.default()
		
		let type = downloadObject.remoteURL.pathExtension
		guard let localURL = FileManager.createUrlFor(fileType: type) else {
			
			self.didFail()
			return
		}
		awsTransferUtility.download(to: localURL, bucket: bucketName, key: downloadObject.fileName, expression: expression, completionHandler: completionHandler)
    }
	
	private func processImage(data: Data?, completion: completionBlock?) {
		guard let data = data, let image = UIImage(data: data) else {
			if let completionBlock = completion {
				completionBlock(downloadObject, nil)
			}
			return
		}
		do {
			let imageObject = try UIImage.set(image: image, imagePath: nil, thumbnailPath: nil)
			if let imagePath = URL(string: imageObject.imagePath), let thumbPath = URL(string: imageObject.thumbPath) {
				downloadObject.localURL = imagePath
				downloadObject.localThumbURL = thumbPath
			}
			if let completionBlock = completion {
				completionBlock(downloadObject, nil)
			}
		} catch let error {
			if let completionBlock = completion {
				completionBlock(downloadObject, TransferError.writeError(error))
			}
		}
	}

	
}
