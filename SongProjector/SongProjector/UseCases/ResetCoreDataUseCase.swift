//
//  ResetCoreDataUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

struct ResetCoreDataUseCase {
    
    private let mocBackground = newMOCBackground
    
    func reset(completion: @escaping (() -> Void)) throws {
        DispatchQueue.global().async {
            do {
                DeleteAllFilesUseCase().delete()
                mocBackground.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                try mocBackground.performAndWait {
                    let entities: [Entity] = DataFetcher().getEntities(moc: mocBackground, fetchDeleted: true)
                    entities.forEach { entity in
                        mocBackground.delete(entity)
                    }
                    try mocBackground.save()
                    try moc.save()
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}
