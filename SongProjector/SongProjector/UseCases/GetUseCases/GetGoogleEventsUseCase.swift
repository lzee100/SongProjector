//
//  GetGoogleEventsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 03/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor GetGoogleEventsUseCase {

    private let context = newMOCBackground

    func get() async -> [GoogleActivityCodable] {
        let request: NSFetchRequest<GoogleActivity> = GetCoreDataRequestUseCase.get()

        return await context.perform {
            do {
                let entities = try self.context.fetch(request)
                return entities.compactMap({ GoogleActivityCodable(entity: $0) })
            } catch {
                return []
            }
        }
    }
}
