//
//  AmazonUploader.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/02/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit



class AmazonTransfer: NSObject {
	
	var state: TransferState = .idle
	
	private var transfers: [[Foundation.Operation]] = []
	private var delegate: TransferDelegate?
	
	static func startTransfer(uploads: [UploadObject], downloads: [DownloadObject], completion: @escaping ((_ result: TransferResult) -> Void)) {
		
		var operations: [Foundation.Operation] = uploads.compactMap({ FileUploadOperation(uploadObject: $0) })
		operations += downloads.compactMap({ FileDownloadOperation(downloadObject: $0) })
		
		let finishOperation = BlockOperation {
			
			let uploadOperations = operations.compactMap({ $0 as? FileUploadOperation })
			let downloadOperations = operations.compactMap({ $0 as? FileDownloadOperation })
			
			let uploadError = uploadOperations.compactMap({ $0.error }).first
			let downLoadError = downloadOperations.compactMap({ $0.error }).first

			
			if let error = uploadError ?? downLoadError {
				completion(.failed(error: error))
			} else {
				
				let uploadObjects = uploadOperations.compactMap({ $0.uploadObject })
				let downloadObjects = downloadOperations.compactMap({ $0.downloadObject })
				
				// upload with same files, upload only once to amazon, and set all urls for the same file
				uploadObjects.forEach { uploadObject in
					if let remoteURL = uploadObject.remoteURL {
						uploadObjects.forEach { (uploadObject2) in
							if uploadObject !== uploadObject2, uploadObject.localURL == uploadObject2.localURL {
								uploadObject2.remoteURL = remoteURL
							}
						}
					}
				}
				
				downloadObjects.forEach { downloadObject in
					if let localURL = downloadObject.localURL {
						downloadObjects.forEach { (downloadObject2) in
							if downloadObject.remoteURL == downloadObject2.remoteURL {
								downloadObject2.localURL = localURL
								downloadObject2.localThumbURL = downloadObject.localThumbURL
							}
						}
					}
				}
				completion(.success(result: uploadObjects + downloadObjects))
			}
		}
		
		
		operations += [finishOperation]

		var previous: Foundation.Operation?
		operations.forEach { (operation) in
			previous?.completionBlock = {
				let error = (previous as? FileUploadOperation)?.error ?? (previous as? FileDownloadOperation)?.error
				if ((previous is FileUploadOperation) || (previous is FileDownloadOperation)) {
					if error != nil || (previous?.isCancelled ?? false) {
						operation.cancel()
					}
				}
				OperationQueue().addOperation(operation)
			}
			previous = operation
		}
		
		OperationQueue().addOperations([operations.first!], waitUntilFinished: false)
	}
	
//	func transferDidChange(operation: Foundation.Operation, bytesTransfered: Int64, totalBytes: Int64) {
//		if let tranfsers = self.transfers.first(where: { transfers in
//			transfers.contains(operation)
//		}) {
//			let totalBytes = tranfsers.compactMap({ $0 as? TransferOperation }).compactMap({ $0.totalBytes }).reduce(0, +)
//			let bytesTransfered = tranfsers.compactMap({ $0 as? TransferOperation }).compactMap({ $0.bytesTransfered }).reduce(0, +)
//
//			delegate?.transferDidChange(operation, bytesTransfered: bytesTransfered, total: totalBytes)
//		}
//	}
	
}



enum TransferType: String {
	case jpg
	case jpeg
	case mp3
	case m4a
	
	static let allValues: [TransferType] = [.jpg, .jpeg, .mp3, .m4a]
	
	var mimeType: String {
		switch self {
		case .jpeg, .jpg: return "image/jpeg"
		case .mp3: return "audio/mpeg"
		case .m4a: return "audio/m4a"
		}
	}
	
	init?(fileExtension: String?) {
		if let uploadType = TransferType.allValues.first(where: { $0.rawValue == fileExtension }) {
			self = uploadType
		} else {
			return nil
		}
	}
	
}

class TransferObject {
	let fileName: String
	
	init(fileName: String) {
		self.fileName = fileName
	}
}

class UploadObject: TransferObject {
	let localURL: URL
	var remoteURL: URL? = nil
	let transferType: TransferType
	
	init?(localURL: URL) {
		self.localURL = localURL
		if let transferType = TransferType(fileExtension: localURL.pathExtension) {
			self.transferType = transferType
		} else {
			return nil
		}
		super.init(fileName: localURL.lastPathComponent)
	}
}

class DownloadObject: TransferObject, Equatable {
	
	var localURL: URL?
	var localThumbURL: URL?
	let remoteURL: URL
	
	init(remoteURL: URL) {
		self.remoteURL = remoteURL
		super.init(fileName: remoteURL.lastPathComponent)
	}
	
	static func == (lhs: DownloadObject, rhs: DownloadObject) -> Bool {
		return lhs.remoteURL == rhs.remoteURL
	}
	
}


enum TransferState {
	case idle
	case preparing
	case transferReady
	case transfering(bytesTransfered: Int64, total: Int64)
	case finished(result: TransferResult)
}

enum TransferResult {
	case failed(error: Error)
	case success(result: [TransferObject])
}

protocol TransferDelegate {
	
	var state: TransferState { get }
	func transferDidstart()
	func transferDidChange(_ operation: Foundation.Operation, bytesTransfered: Int64, total: Int64)
	func transferDidComplete(result: TransferResult)
}

