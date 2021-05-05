//
//  TransferManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation


protocol TransferManagerDelegate {
    func uploadDidProgress(progress: Double)
    func didComplete(result: TransferResult)
}

class TransferManager: NSObject {
    var delegate: TransferManagerDelegate?
    
    var downloadObjects: [DownloadObject] {
        return singleTransferManagers.compactMap({ $0.transferObject as? DownloadObject })
    }
    var uploadObjects: [UploadObject] {
        return singleTransferManagers.compactMap({ $0.transferObject as? UploadObject })
    }
    
    private let singleTransferManagers: [SingleTransferManager]
    private var progress: Double = 0
   
    init(objects: [TransferObject]) {
        let uploadObject = objects.compactMap({ $0 as? UploadObject })
        let downloadObjects = objects.compactMap({ $0 as? DownloadObject })
        let uploaders = uploadObject.map({ FileSubmitter(transferObject: $0) })
        let downLoaders = downloadObjects.map({ FileFetcher(transferObject: $0) })
        self.singleTransferManagers = uploaders + downLoaders
    }
    
    init(singleTransferManagers: [SingleTransferManager]) {
        self.singleTransferManagers = singleTransferManagers
    }
    
    func start(progress: @escaping ((Double) -> Void), completion: @escaping ((_ result: TransferResult) -> Void)) {
        
        func startTransfer(_ singleTransferManager: SingleTransferManager) {
            singleTransferManager.perform(progress: { (_) in
                self.progress = self.singleTransferManagers.map({ $0.progress }).reduce(0, +) / Double(self.singleTransferManagers.count)
                progress(self.progress)
                self.delegate?.uploadDidProgress(progress: self.progress)
            }) { (result) in
                self.delegate?.didComplete(result: result)
                switch result {
                case .failed(error: _): completion(result)
                case .success:
                    if let submitter = self.singleTransferManagers.filter({ $0.readyToUpload }).first {
                        startTransfer(submitter)
                    } else {
                        completion(.success)
                    }
                }
            }
        }
        
        if let submitter = singleTransferManagers.first {
            startTransfer(submitter)
        } else {
            completion(.success)
        }
    }
    
}
