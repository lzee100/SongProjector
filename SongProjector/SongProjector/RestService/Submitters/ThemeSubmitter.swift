//
//  ThemeSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

let ThemeSubmitter = TemeSubmitter()

class TemeSubmitter: Requester<VTheme> {
    
    override var id: String {
        return "ChurchBeamUserSubmitter"
    }
    override var path: String {
        return "themes"
    }
    
    override func prepareForSubmit(body: [VTheme], completion: @escaping ((Requester<VTheme>.AdditionalProcessResult) -> Void)) {
        
        var deletableFiles: [StorageReference] = []
        
        do {
            try body.forEach { theme in
                if theme.isTempSelectedImageDeleted || self.requestMethod == .delete {
                    if let name = theme.imagePathAWS {
                        let uploadFile = Storage.storage().reference().child("images").child(name)
                        deletableFiles.append(uploadFile)
                    }
                } else if let image = theme.tempSelectedImage {
                    if let name = theme.imagePathAWS {
                        let uploadFile = Storage.storage().reference().child("images").child(name)
                        deletableFiles.append(uploadFile)
                    }
                    theme.tempLocalImageName = try image.saveTemp()
                }
            }
        } catch {
            completion(.failed(error: .failedSavingImageLocallyBeforeSubmit(requester: self.id, error: error)))
            return
        }
        
        let uploadObjects = body.flatMap({ $0.uploadObjecs }).unique { (lhs, rhs) -> Bool in
            return lhs.fileName == rhs.fileName
        }
        let uploadManager = TransferManager(transferObjects: uploadObjects)
        
        _ = uploadManager.$result.sink { result in
            switch result {
            case .failed(error: let error):
                body.compactMap({ $0.tempLocalImageName }).forEach { try? FileManager.deleteFile(name: $0) }
                completion(.failed(error: .failedUploadingMedia(requester: self.id, error: error)))
            case .success, .none:
                
                self.deleteLocalImages(body: body)
                
                var failed = false
                for theme in body {
                    do {
                        if let image = theme.tempSelectedImage {
                            try theme.setBackgroundImage(image: image, imageName: theme.imagePath)
                        }
                    } catch let error {
                        failed = true
                        completion(.failed(error: .failedSavingLocalImage(requester: self.id, error: error)))
                        break
                    }
                    theme.setUploadValues(uploadObjects)
                }
                if !failed {
                    deletableFiles.forEach({ $0.delete(completion: nil) })
                    completion(.succes(result: body))
                }
            }
        }
        
    }
    
    override func submit(_ entity: [VTheme], requestMethod: RequestMethod) {
        super.submit(entity, requestMethod: requestMethod)
    }
    
    private func deleteLocalImages(body: [VTheme]) {
        body.forEach { theme in
            if theme.isTempSelectedImageDeleted {
                try? theme.setBackgroundImage(image: nil, imageName: nil)
            }
        }
    }

    
}
