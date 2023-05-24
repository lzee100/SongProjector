//
//  FileUploadUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import CoreData
import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import SwiftUI

actor FileUploadsUseCase<T: FileTransferable> {
    
    func startUploadingFor(_ entity: T) async throws -> T {
        let submitters = entity.uploadObjects
            .compactMap { $0 as? UploadObject }
            .map { FileSubmitter(uploadObject: $0) }
        
        let transferObjects = try await submitFiles(submitters)
        var changableEntity = entity
        try changableEntity.setTransferObjects(transferObjects)
        return changableEntity
    }
    
    private func submitFiles(_ submitters: [FileSubmitter]) async throws -> [TransferObject] {
        try await withThrowingTaskGroup(of: TransferObject.self) { group in
            for submitter in submitters {
                group.addTask {
                    let result = try await submitter.startTransfer()
                    return result
                }
            }
            var results: [TransferObject] = []
            for try await (result) in group {
                results.append(result)
            }
            return results
        }
    }
}
