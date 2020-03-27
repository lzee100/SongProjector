//
//  FileUploader.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/02/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore

protocol TransferOperation {
	var progress: Double { get }
}

protocol TransferChange {
	func transferDidChange(operation: Foundation.Operation, transferred: Int, total: Int)
}

class FileUploadOperation: AsynchronousOperation, TransferOperation {
    let bucketName = "churchbeam-europe-central"
	
	let uploadObject: UploadObject
	let delegate: TransferChange?
	var progress: Double = 0
	var error: Error?
	
	init(uploadObject: UploadObject, delegate: TransferChange) {
		self.uploadObject = uploadObject
		self.delegate = delegate
	}
	
	init(uploadObject: UploadObject) {
		self.uploadObject = uploadObject
		self.delegate = nil
	}

	
	override func main() {
		super.main()
		
		prepare {
			self.startUploading()
		}
		
	}
	
	
	func prepare(completion: (() -> Void)) {
		
		// url to data???
		
		completion()
	}
	
	func startUploading() {
		
		uploadfile(fileUrl: uploadObject.localURL, fileName: uploadObject.fileName, contenType: uploadObject.transferType.mimeType, progress: { (transferred, total) in
			self.delegate?.transferDidChange(operation: self, transferred: transferred ?? 0, total: total ?? 0)
		}) { (result, error) in
			if let error = error {
				self.error = error
				self.didFail()
			} else {
				self.uploadObject.remoteURL = result as? URL
				self.didFinish()
			}
		}
		
	}
	
	private func uploadfile(fileUrl: URL, fileName: String, contenType: String, progress: progressBlock?, completion: completionBlock?) {
        // Upload progress block
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, awsProgress) in
            guard let uploadProgress = progress else { return }
            DispatchQueue.main.async {
                uploadProgress(awsProgress.fileCompletedCount, awsProgress.fileTotalCount)
            }
        }
        // Completion block
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error == nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(self.bucketName).appendingPathComponent(fileName)
                    print("Uploaded to:\(String(describing: publicURL))")
					completion?(publicURL, nil)
                } else {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(self.bucketName).appendingPathComponent(fileName)
					completion?(nil, error)
                }
            })
        }
        // Start uploading using AWSS3TransferUtility
        let awsTransferUtility = AWSS3TransferUtility.default()
        awsTransferUtility.uploadFile(fileUrl, bucket: bucketName, key: fileName, contentType: contenType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
            if let error = task.error {
				completion?(nil, error)
                print("error is: \(error.localizedDescription)")
            }
            return nil
        }
    }
	
	
	
}
