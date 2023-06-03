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


actor FileFetcher: SingleTransferManagerProtocol {
    
    enum FileFetcherError: LocalizedError {
        case noFileOnAmazonStorageFound
        
        var errorDescription: String? {
            switch self {
            case .noFileOnAmazonStorageFound: return "No image / video found on aws for this url (deleted on aws?)"
            }
        }
    }
    
    let downloadObject: DownloadObject
    
    init(downloadObject: DownloadObject) {
        self.downloadObject = downloadObject
    }
    
    func startTransfer() async throws -> TransferObject {
        do {
            let storageRef = Storage.storage().reference()
            
            var subPath: String {
                switch downloadObject.type {
                case .jpeg, .jpg, .png: return SingleTransferManagerConstants.images
                case .m4a: return SingleTransferManagerConstants.audio
                }
            }
            
            let downloadFile = storageRef.child(subPath).child(downloadObject.filename)
            let locURL = GetFileURLUseCase(fileName: downloadObject.filename).getURL(location: .persitent)
            
            guard (try? await downloadFile.writeAsync(toFile: locURL)) != nil else {
                throw FileFetcherError.noFileOnAmazonStorageFound
            }
            
            if downloadObject.isVideo {
                downloadObject.localURL = URL(string: downloadObject.filename)
            } else {
                let data = try Data(contentsOf: locURL)
                if let image = UIImage(data: data) {
                    downloadObject.image = image
                } else {
                    throw TransferError.downloadNoLocalImage
                }
            }
            return downloadObject
        } catch {
            print(error)
            throw error
        }
    }
}
