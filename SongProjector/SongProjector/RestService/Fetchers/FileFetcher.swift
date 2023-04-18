//
//  FileFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage


class FileFetcher: SingleTransferManagerProtocol {
    
    private let downloadObject: DownloadObject
    
    var transferObject: TransferObject {
        return downloadObject
    }
    
    required init(downloadObject: DownloadObject) {
        self.downloadObject = downloadObject
    }
    
    func startTransfer() async throws -> TransferResult {
        let storageRef = Storage.storage().reference()
        
        var subPath: String {
            switch downloadObject.type {
            case .jpeg, .jpg, .png: return SingleTransferManagerConstants.images
            case .m4a: return SingleTransferManagerConstants.audio
            }
        }
        
        let downloadFile = storageRef.child(subPath).child(downloadObject.filename)
        let locURL: URL?
        if downloadObject.isVideo {
            locURL = FileManager.getURLfor(name: downloadObject.filename)
        } else {
            locURL = try FileManager.getUrlFor(fileName: downloadObject.filename)
        }
        guard let localURL = locURL else {
            return .failed(error: TransferError.noURLForDownloadingFile)
        }

        let url = try await downloadFile.writeAsync(toFile: localURL)
        if downloadObject.isVideo {
            downloadObject.localURL = URL(string: downloadObject.filename)
            return .success
        } else {
            let data = try Data(contentsOf: localURL)
            if let image = UIImage(data: data) {
                downloadObject.image = image
                return .success
            } else {
                return .failed(error: TransferError.downloadNoLocalImage)
            }
        }
    }
}
