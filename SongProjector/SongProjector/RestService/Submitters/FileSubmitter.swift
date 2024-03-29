//
//  FileSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI

enum FileType: String, CaseIterable {
    case png
    case jpg
    case jpeg
    case m4a
    
    init?(type: String?) {
        if let type = FileType.allCases.first(where: { $0.rawValue == type }) {
            self = type
        } else {
            return nil
        }
    }
    
    var mimeType: String {
        switch self {
        case .png: return "image/png"
        case .jpg, .jpeg: return "image/jpeg"
        case .m4a: return "audio/m4a"
        }
    }
    
}

enum TransferError: LocalizedError {
    case noDataToUpload
    case uploadFailedNoErrorInfo
    case noURLForDownloadingFile
    case downloadNoLocalImage
    case notAnUploadFile
    case notAnDownloadFile
    case couldNotCreateLocalFileDirectory
    
    var localizedDescription: String {
        switch self {
        case .noDataToUpload: return "Could not find selected file to upload"
        case .uploadFailedNoErrorInfo: return "File upload went wrong with no given reason"
        case .downloadNoLocalImage: return "Unable to save image to device"
        case .notAnUploadFile: return "Wrong file to upload"
        case .notAnDownloadFile: return "Wrong file to download"
        case .couldNotCreateLocalFileDirectory: return "Unable to create a local file directory"
        case .noURLForDownloadingFile: return "Unable to get local url to save download to"
        }
    }
}

enum TransferResult {
    case failed(error: LocalizedError)
    case success
    
    var isFailed: Bool {
        switch self {
        case .failed: return true
        case .success: return false
        }
    }
    
    var error: LocalizedError? {
        switch self {
        case .failed(error: let error): return error
        case .success: return nil
        }
    }
}

enum TransferState {
    case idle
    case uploading
    case finished(result: TransferResult)
}

protocol TransferObjectDelegate {
    func transferDidStart()
    func transferProgressed()
    func transferDidFinish()
}

class TransferObject {
    
}

class UploadObject: TransferObject {
    
    let type: FileType
    let fileName: String
    
    var remoteURL: URL? = nil
    
    init?(fileName: String) {
        if let url = URL(string: fileName), let type = FileType(type: url.pathExtension) {
            self.type = type
        } else {
            return nil
        }
        self.fileName = fileName
    }
    
    static func ==(lhs: UploadObject, rhs: UploadObject) -> Bool {
        return lhs.fileName == rhs.fileName
    }
}

class DownloadObject: TransferObject {
    
    var localURL: URL? = nil
    var image: UIImage? = nil
    let type: FileType
    let filename: String
    
    var isVideo: Bool {
        switch type {
        case .jpeg, .jpg, .png: return false
        case .m4a: return true
        }
    }
    
    let remoteURL: URL
    
    init?(remoteURL: URL) {
        self.remoteURL = remoteURL
        if let type = FileType(type: remoteURL.pathExtension) {
            self.type = type
        } else {
            return nil
        }
        filename = remoteURL.lastPathComponent
    }
    
    static func ==(lhs: DownloadObject, rhs: DownloadObject) -> Bool {
        return lhs.remoteURL.absoluteString == rhs.remoteURL.absoluteString
    }
}

protocol SingleTransferManagerProtocol {
    func startTransfer() async throws -> TransferObject
}

struct SingleTransferManagerConstants {
    static let images = "images"
    static let audio = "audio"
}

class FileSubmitter: SingleTransferManagerProtocol {
    
    enum SubmitError: LocalizedError {
        case error(Error)
        
        var errorDescription: String? {
            switch self {
            case .error(let error): return AppText.RequesterErrors.failedUploadingMedia(requester: "", error: error)
            }
        }
    }
    
    let uploadObject: UploadObject
    
    required init(uploadObject: UploadObject) {
        self.uploadObject = uploadObject
    }
    
    func startTransfer() async throws -> TransferObject {
        let storageRef = Storage.storage().reference()
        
        var subPath: String {
            switch uploadObject.type {
            case .jpeg, .jpg, .png: return SingleTransferManagerConstants.images
            case .m4a: return SingleTransferManagerConstants.audio
            }
        }
        
        let uploadFile = storageRef.child(subPath).child(uploadObject.fileName)
        let localURL = GetFileURLUseCase(fileName: uploadObject.fileName).getURL(location: .temp)
        let data = try Data(contentsOf: localURL)
        let metadata = try await uploadFile.putDataAsync(data)
        let url = try await uploadFile.downloadURL()
        uploadObject.remoteURL = url
        return uploadObject
    }
}
