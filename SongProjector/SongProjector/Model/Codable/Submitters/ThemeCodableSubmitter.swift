//
//  ThemeCodableSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import CoreData
import Firebase

struct ThemeCodableSubmitter: CodableFetcherType {
    
    private let requestMethod: RequestMethod
    private let body: [ThemeDraft]
    private let observer: RequesterObserver1?

    
    init(requestMethod: RequestMethod, body: [ThemeDraft], observer: RequesterObserver1) {
        self.requestMethod = requestMethod
        self.body = body
        self.observer = observer
    }
    
    func prepareForSubmit(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
        
        var deletableFiles: [StorageReference] = []
         
        do {
            try deletableFiles = makeDeleteFiles()
        } catch {
            completion(.failure(CodableError.savingTempImage(error: error)))
            return
        }
        
        let uploadObjects = body.flatMap({ $0.uploadObjecs }).unique { (lhs, rhs) -> Bool in
            return lhs.fileName == rhs.fileName
        }
        let uploadManager = TransferManager(objects: uploadObjects)
        
        uploadManager.start(progress: { (progress) in
            self.observer?.requesterDidProgress(progress: CGFloat(progress))
        }) { (result) in
            switch result {
            case .failed(error: let error):
                body.compactMap({ $0.tempSavedImageName }).forEach { try? FileManager.deleteFile(name: $0) }
                completion(.failure(CodableError.uploadingImage(error: error)))
            case .success:
                
                self.deleteLocalImages()
                
                var failed = false
                for theme in body {
                    do {
                        if let image = theme.imageSelectionAction.image {
                            try theme.setBackgroundImage(image: image, imageName: theme.imagePath)
                        }
                    } catch let error {
                        failed = true
                        completion(.failure(CodableError.savingImage(error: error)))
                        break
                    }
                    theme.setUploadValues(uploadObjects)
                }
                if !failed {
                    deletableFiles.forEach({ $0.delete(completion: nil) })
                    completion(.success(body.map { $0.themeCodable }))
                }
            }
        }
    }
    
    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
        
        var submitter = SubmitCodablePerformer<ThemeCodable>(body: body.map { $0.themeCodable }, requestMethod: .put, requesterInfo: ThemeRequesterInfo())
        
        submitter.performSubmit { result in
            switch result {
            case .success(let result): completion(.success(result))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: @escaping (Result<[NSManagedObject], Error>) -> Void) {
        completion(.success(managedObjects))
    }
    
    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType] {
        objects.compactMap { TagCodable(managedObject: $0, context: context) }
    }
    
    private func makeDeleteFiles() throws -> [StorageReference] {
        var deletableFiles: [StorageReference] = []
        
        try body.forEach { theme in
            guard let awsPath = theme.imagePathAWS else {
                return
            }
            if theme.imageSelectionAction.needsDeletion || self.requestMethod == .delete {
                let uploadFile = Storage.storage().reference().child("images").child(awsPath)
                deletableFiles.append(uploadFile)
            }
            theme.tempSavedImageName = try theme.imageSelectionAction.image?.saveTemp()
        }
        
        return deletableFiles
    }
    
    private func deleteLocalImages() {
        body.forEach { theme in
            if case .delete = theme.imageSelectionAction {
                try? theme.setBackgroundImage(image: nil, imageName: nil)
            }
        }
    }

}
