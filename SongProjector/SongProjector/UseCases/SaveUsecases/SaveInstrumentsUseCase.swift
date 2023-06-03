//
//  SaveInstrumentsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveInstrumentsUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [InstrumentCodable]) async throws {
        
        try await context.perform {
            try entities.forEach { instrument in
                try self.getInstrument(instrument)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    func getInstrument(_ instrument: InstrumentCodable) throws -> NSManagedObject {
        
        let instrumentsEmpty: [Instrument] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: instrument.id)], fetchDeleted: true)
        
        if let entity = instrumentsEmpty.first {
            try setProperties(fromInstrument: instrument, to: entity)
            return entity
        } else {
            let entity: Instrument = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromInstrument: instrument, to: entity)
            return entity
        }
    }
    
    private func setProperties(fromInstrument instrument: InstrumentCodable, to entity: Instrument) throws {
        entity.id = instrument.id
        entity.userUID = instrument.userUID
        entity.title = instrument.title
        entity.createdAt = instrument.createdAt.nsDate
        entity.updatedAt = instrument.updatedAt?.nsDate
        entity.deleteDate = instrument.deleteDate?.nsDate
        entity.rootDeleteDate = instrument.rootDeleteDate?.nsDate
        
        entity.isLoop = instrument.isLoop
        entity.resourcePath = instrument.resourcePath
        entity.typeString = instrument.typeString
        entity.resourcePathAWS = instrument.resourcePathAWS
    }
}
