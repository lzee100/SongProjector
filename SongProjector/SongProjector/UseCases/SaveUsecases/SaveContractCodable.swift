//
//  SaveContractCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveContractCodable {
    
    private let context = newMOCBackground
    
    func save(entities: [ContractCodable]) async throws {
                
        try await context.perform {
            try entities.forEach { contract in
                try self.get(contract)
            }
            try self.context.save()
        }
        try await self.context.parent?.perform {
            try self.context.parent?.save()
        }
    }
    
    @discardableResult
    private func get(_ contract: ContractCodable) throws -> NSManagedObject {
        
        let contracts: [Contract] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: contract.id)], fetchDeleted: true)
        
        if let entity = contracts.first {
            try setProperties(from: contract, to: entity)
            return entity
        } else {
            let entity: Contract = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(from: contract, to: entity)
            return entity
        }
    }

    private func setProperties(from codable: ContractCodable, to entity: Contract) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate
    }
}

