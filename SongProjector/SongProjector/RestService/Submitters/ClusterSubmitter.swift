//
//  ClusterSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let ClusterSubmitter = CsterSubmitter()

class CsterSubmitter: Requester<VCluster> {
    
    override var id: String {
        return "ClusterSubmitter"
    }
    override var path: String {
        return "clusters"
    }
    
    var dontUploadFiles: Bool = false {
        didSet {
            print("pla")
        }
    }
    var uploadMusic: Bool {
        return false
    }
    
    override func prepareForSubmit(body: [VCluster], completion: @escaping ((Requester<VCluster>.AdditionalProcessResult) -> Void)) {
        
        // don't upload objects as the objects are already uploaded in the universal cluster (allready had links on google for images / audio)
        if dontUploadFiles {
            completion(.succes(result: body))
            dontUploadFiles = false
            return
        }
        
        guard requestMethod != .delete else {
            completion(.succes(result: body))
            return
        }
        
        var deletableFiles: [String] = body.flatMap({ $0.deletedSheetsImageURLs })
        
        // set new temp images
        // deleted images will be removed locally when call is succesfull
        do {
            try body.forEach({ cluster in
                try cluster.hasSheets.forEach({ sheet in
                    if let image = sheet.hasTheme?.tempSelectedImage {
                        if let url = sheet.hasTheme?.imagePathAWS {
                            deletableFiles.append(url)
                        }
                        sheet.hasTheme?.tempLocalImageName = try image.saveTemp()
                    }
                })
                try cluster.hasSheets.compactMap({ $0 as? VSheetTitleImage }).forEach({ sheet in
                    if let image = sheet.tempSelectedImage {
                        if let url = sheet.imagePathAWS {
                            deletableFiles.append(url)
                        }
                        sheet.tempLocalImageName = try image.saveTemp()
                    }
                })
                try cluster.hasSheets.compactMap({ $0 as? VSheetPastors }).forEach({ sheet in
                    if let image = sheet.tempSelectedImage {
                        if let url = sheet.imagePathAWS {
                            deletableFiles.append(url)
                        }
                        sheet.tempLocalImageName = try image.saveTemp()
                    }
                })
            })
        } catch {
            completion(.failed(error: .failedSavingImageLocallyBeforeSubmit(requester: self.id, error: error)))
            return
        }
       
        // get upload objects from temp directories
        let uploadObjects = body.filter({ $0.deleteDate == nil }).flatMap({ $0.uploadObjecs + (uploadMusic ? $0.uploadMusicObjects : []) }).unique { (lhs, rhs) -> Bool in
            return lhs.fileName == rhs.fileName
        }
        let uploadManager = TransferManager(objects: uploadObjects)
        
        uploadManager.start(progress: { (progress) in
            self.observers.forEach({ $0.requesterDidProgress(progress: CGFloat(progress)) })
        }) { (result) in
            switch result {
            case .failed(error: let error): completion(.failed(error: .failedUploadingMedia(requester: self.id, error: error)))
            case .success:
                FileDeleter.delete(files: deletableFiles)
                do {
                    try body.forEach({
                        try $0.setUploadValues(uploadObjects)
                    })
                } catch let error {
                    completion(.failed(error: .failedSavingLocalImage(requester: self.id, error: error)))
                    return
                }
                self.deleteFilesLocallyIfNeeded(body: self.body)
                completion(.succes(result: body))
            }
        }
        
    }
    
    override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VCluster], completion: @escaping ((Requester<VCluster>.AdditionalProcessResult) -> Void)) {
        
        guard requestMethod != .delete else {
            completion(.succes(result: entities))
            return
        }
        
        // don't download music objects, should be done manually
        let downloadObjects = entities.filter({ $0.deleteDate == nil }).flatMap({ $0.downloadObjects }).unique { (lhs, rhs) -> Bool in
            return lhs.remoteURL == rhs.remoteURL
        }
        let downloadManager = TransferManager(objects: downloadObjects)
        
        downloadManager.start(progress: { (progress) in

        }) { (result) in
            switch result {
            case .failed(error: let error): completion(.failed(error: .failedDownloadingMedia(requester: self.id, error: error)))
            case .success:
                entities.forEach({
                    $0.setDownloadValues(downloadObjects)
                })
                completion(.succes(result: entities))
            }
        }

        
    }
    
    private func deleteFilesLocallyIfNeeded(body: [VCluster]) {
        body.forEach({ cluster in
            cluster.hasSheets.forEach({ sheet in
                if sheet.hasTheme?.isTempSelectedImageDeleted ?? false {
                    try? sheet.hasTheme?.setBackgroundImage(image: nil, imageName: nil)
                }
            })
            cluster.hasSheets.compactMap({ $0 as? VSheetTitleImage }).forEach({ sheet in
                if sheet.isTempSelectedImageDeleted {
                    try? sheet.set(image: nil, imageName: nil)
                }
            })
            cluster.hasSheets.compactMap({ $0 as? VSheetPastors }).forEach({ sheet in
                if sheet.isTempSelectedImageDeleted {
                    try? sheet.set(image: nil, imageName: nil)
                }
            })
        })
    }
    
}
