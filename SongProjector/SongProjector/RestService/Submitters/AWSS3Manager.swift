////
////  AWSS3Manager.swift
////  SongProjector
////
////  Created by Leo van der Zee on 16/02/2020.
////  Copyright © 2020 iozee. All rights reserved.
//
//
//import Foundation
//import UIKit
//import AWSS3 //1
//
//typealias progressBlock = (_ bytesTransferred: Int?, _ total: Int?) -> Void
//typealias completionBlock = (_ response: Any?, _ error: Error?) -> Void
//
//class AWSS3Manager {
//
//    static let shared = AWSS3Manager() // 4
//    private init () { }
//    let bucketName = "***** your bucket name *****" //5
//
//    // Upload image using UIImage object
//	func uploadImage(uploadObject: UploadObject, progress: progressBlock?, completion: completionBlock?) {
//		self.uploadfile(fileUrl: uploadObject.localURL, fileName: uploadObject.fileName, contenType: uploadObject.uploadType.mimeType, progress: progress, completion: completion)
//    }
//
//    // Upload video from local path url
//    func uploadVideo(uploadObject: UploadObject, progress: progressBlock?, completion: completionBlock?) {
//		let fileName = self.getUniqueFileName(fileUrl: uploadObject.localURL)
//		self.uploadfile(fileUrl: uploadObject.localURL, fileName: fileName, contenType: "video", progress: progress, completion: completion)
//    }
//
//    // Upload auido from local path url
//    func uploadAudio(uploadObject: UploadObject, progress: progressBlock?, completion: completionBlock?) {
//		self.uploadfile(fileUrl: uploadObject.localURL, fileName: uploadObject.fileName, contenType: "audio", progress: progress, completion: completion)
//    }
//
//    // Upload files like Text, Zip, etc from local path url
//	func uploadOtherFile(uploadObject: UploadObject, progress: progressBlock?, completion: completionBlock?) {
//		self.uploadfile(fileUrl: uploadObject.localURL, fileName: uploadObject.fileName, contenType: uploadObject.uploadType.mimeType, progress: progress, completion: completion)
//    }
//
//    // Get unique file name
//    func getUniqueFileName(fileUrl: URL) -> String {
//        let strExt: String = "." + (URL(fileURLWithPath: fileUrl.absoluteString).pathExtension)
//        return (ProcessInfo.processInfo.globallyUniqueString + (strExt))
//    }
//
//    //MARK:- AWS file upload
//    // fileUrl :  file local path url
//    // fileName : name of file, like "myimage.jpeg" "video.mov"
//    // contenType: file MIME type
//    // progress: file upload progress, value from 0 to 1, 1 for 100% complete
//    // completion: completion block when uplaoding is finish, you will get S3 url of upload file here
//
//
//
//
//
//
//}
