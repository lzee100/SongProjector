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
    
    func save(entities: [InstrumentCodable], deleteLocalResourcePath: Bool = false) async throws {
        
        try await context.perform {
            try entities.forEach { instrument in
                try self.getInstrument(instrument, deleteLocalResourcePath: deleteLocalResourcePath)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    func getInstrument(_ instrument: InstrumentCodable, deleteLocalResourcePath: Bool) throws -> NSManagedObject {
        
        let instrumentsEmpty: [Instrument] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: instrument.id)], fetchDeleted: true)
        
        if let entity = instrumentsEmpty.first {
            try setProperties(fromInstrument: instrument, to: entity, deleteLocalResourcePath: deleteLocalResourcePath)
            return entity
        } else {
            let entity: Instrument = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromInstrument: instrument, to: entity, deleteLocalResourcePath: deleteLocalResourcePath)
            return entity
        }
    }
    
    private func setProperties(fromInstrument instrument: InstrumentCodable, to entity: Instrument, deleteLocalResourcePath: Bool) throws {
        entity.id = instrument.id
        entity.userUID = instrument.userUID
        entity.title = instrument.title
        entity.createdAt = instrument.createdAt.nsDate
        entity.updatedAt = instrument.updatedAt?.nsDate
        entity.deleteDate = instrument.deleteDate?.nsDate
        entity.rootDeleteDate = instrument.rootDeleteDate?.nsDate
        
        entity.isLoop = instrument.isLoop
        
        if deleteLocalResourcePath {
            entity.resourcePath = nil
        } else if let resourcePath = instrument.resourcePath {
            entity.resourcePath = resourcePath
        }
        
        entity.typeString = instrument.typeString
        entity.resourcePathAWS = instrument.resourcePathAWS
    }
}
