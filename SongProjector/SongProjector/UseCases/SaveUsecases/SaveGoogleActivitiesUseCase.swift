//
//  SaveGoogleActivitiesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import CoreData
import Foundation

actor SaveGoogleActivitiesUseCase {
    private let context = newMOCBackground

    func save(entities: [GoogleCalendarEventDictionary]) async throws {
        try await deleteAllOldActivities()

        try await context.perform {
            entities.forEach { activity in
                let entity: GoogleActivity = CreatePersistentEntityUseCase.create(context: self.context)
                entity.id = UUID().uuidString
                entity.createdAt = activity.startDate.nsDate
                entity.userUID = "0"
                entity.startDate = activity.startDate.nsDate
                entity.endDate = activity.endDate.nsDate
                entity.title = activity.summary
            }
            try self.context.save()
        }
        try await context.parent?.perform {
            try self.context.parent?.save()
        }
    }

    private func deleteAllOldActivities() async throws {
        let request: NSFetchRequest<GoogleActivity> = GetCoreDataRequestUseCase.get(fetchDeleted: true)
        try await context.perform {
            let result = try self.context.fetch(request)
            result.forEach { self.context.delete($0) }
            try self.context.save()
        }
        try await context.parent?.perform {
            try self.context.parent?.save()
        }
    }
}
