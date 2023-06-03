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
import FirebaseStorage

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
        let uploadManager = TransferManager(transferObjects: uploadObjects)
        
        _ = uploadManager.$progress.sink { progress in
            self.observer?.requesterDidProgress(progress: CGFloat(progress))
        }
        _ = uploadManager.$result.sink(receiveValue: { result in
            switch result {
            case .failed(error: let error):
                completion(.failure(CodableError.uploadingImage(error: error)))
            case .success, .none:
                self.deleteLocalImages()
                
                var failed = false
                for theme in body {
                    do {
                        if let image = theme.imageSelectionAction.image {
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
                    do {
                        completion(.success( try body.map { try $0.makeCodable() }))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        })
    }
    
    func perform(completion: @escaping ((Result<[EntityCodableType], Error>) -> Void)) {
        observer?.requesterDidStart()
        prepareForSubmit { result in
            switch result {
            case .success:
//                let submitter = SubmitCodablePerformer<ThemeCodable>(body: (themes as? [ThemeCodable] ?? []), requestMethod: requestMethod, requesterInfo: ThemeRequesterInfo())
//
//                submitter.performSubmit { result in
//                    switch result {
//                    case .success(let result):
//                        completion(.success(result))
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
                print("not done yet")
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func additionalProcessing(decodedEntities: [EntityCodableType], managedObjects: [NSManagedObject], context: NSManagedObjectContext, completion: @escaping (Result<[NSManagedObject], Error>) -> Void) {
        completion(.success(managedObjects))
    }
    
    func getCodableObjectFrom(_ objects: [NSManagedObject], context: NSManagedObjectContext) -> [EntityCodableType] {
        objects.compactMap { TagCodable(entity: $0 as! Tag) }
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
//            theme.tempSavedImageName = try theme.imageSelectionAction.image?.saveTemp()
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
