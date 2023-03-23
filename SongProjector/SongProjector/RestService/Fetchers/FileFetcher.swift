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


class FileFetcher: SingleTransferManager {
    
    override func startDownload(progress: @escaping ((Double) -> Void), completion: @escaping ((TransferResult) -> Void)) {
        
        guard let downloadObject = transferObject as? DownloadObject else {
            self.state = .finished(result: .failed(error: TransferError.notAnDownloadFile))
            completion(.failed(error: TransferError.notAnDownloadFile))
            return
        }
        
        let storageRef = Storage.storage().reference()
        
        var subPath: String {
            switch downloadObject.type {
            case .jpeg, .jpg, .png: return Constants.images
            case .m4a: return Constants.audio
            }
        }
        
        let downloadFile = storageRef.child(subPath).child(downloadObject.filename)
        
        do {
            
            let locURL: URL?
            if downloadObject.isVideo {
                locURL = FileManager.getURLfor(name: downloadObject.filename)
            } else {
                locURL = try FileManager.getUrlFor(fileName: downloadObject.filename)
            }
            
            guard let localURL = locURL else {
                completion(.failed(error: TransferError.noURLForDownloadingFile))
                return
            }

            let downloadTask = downloadFile.write(toFile: localURL) { url, error in
                if let error = error {
                    self.state = TransferState.finished(result: .failed(error: error))
                    completion(.failed(error: error))
                } else if url != nil {
                    do {
                        if downloadObject.isVideo {
                            downloadObject.localURL = URL(string: downloadObject.filename)
                            self.state = TransferState.finished(result: .success)
                            completion(.success)
                        } else {
                            let data = try Data(contentsOf: localURL)
                            if let image = UIImage(data: data) {
                                downloadObject.image = image
                                self.state = TransferState.finished(result: .success)
                                completion(.success)
                            } else {
                                self.state = TransferState.finished(result: .failed(error: TransferError.downloadNoLocalImage))
                                completion(.failed(error: TransferError.downloadNoLocalImage))
                            }
                        }
                    } catch {
                        self.state = TransferState.finished(result: .failed(error: error))
                        completion(.failed(error: error))
                    }
                } else {
                    self.state = TransferState.finished(result: .failed(error: TransferError.uploadFailedNoErrorInfo))
                    completion(.failed(error: TransferError.uploadFailedNoErrorInfo))
                }
                
            }
            
            downloadTask.observe(.progress) { snapshot in
                self.progress = snapshot.progress?.fractionCompleted ?? 1
                progress(self.progress)
            }

        } catch {
            self.state = TransferState.finished(result: .failed(error: error))
            completion(.failed(error: error))
        }
        
    }
}
