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
    private var continueAfterFailure = true
    let uploadObjects: [UploadObject]
    let downloadObjects: [DownloadObject]
    @Published private(set) var progress: Double = 0
    @Published private(set) var result: TransferResult?
        
    private var singleTransferManagers: [SingleTransferManagerProtocol]
    
    init(singleTransferManagers: [SingleTransferManagerProtocol]) {
        uploadObjects = []
        downloadObjects = []
        self.singleTransferManagers = singleTransferManagers
    }
    
    init(transferObjects: [TransferObject]) {
        uploadObjects = transferObjects.compactMap { $0 as? UploadObject }
        downloadObjects = transferObjects.compactMap { $0 as? DownloadObject }
        self.singleTransferManagers = uploadObjects.map { FileSubmitter(transferObject: $0) } + downloadObjects.map { FileFetcher(downloadObject: $0) }
    }
    
    func start() {
        startTransfer()
    }
    
    private func startTransfer() {
//        let transferManager = singleTransferManagers.first
//        transferManager?.startTransfer()
//        _ = transferManager?.progress.sink(receiveValue: { [weak self] progress in
//            guard let self = self else { return }
//            self.progress = (progress + Double(self.singleTransferManagers.count - 1)) / Double(self.singleTransferManagers.count)
//        })
//        _ = transferManager?.result.sink(receiveValue: { [weak self] result in
//            switch result {
//            case .success, .none:
//                self?.singleTransferManagers.removeFirst()
//                self?.startTransfer()
//            case .failed:
//                self?.result = result
//            }
//        })
    }
    
}
