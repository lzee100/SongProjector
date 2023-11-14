//
//  SaveTagInSchemeUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveTagInSchemeUseCase {

    private let context = newMOCBackground

    func save(entities: [TagInSchemeCodable]) async throws {

        try await context.perform {
            try entities.forEach { tag in
                try GetTagInSchemeUseCase.get(tag, context: self.context)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }


}
