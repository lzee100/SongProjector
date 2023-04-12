//
//  OrganisatieCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct OrganisatieCodable: EntityCodableType {
    
    init?(managedObject: NSManagedObject, context: NSManagedObjectContext) {
        guard let entity = managedObject as? Organization else { return nil }
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
        
        if let roles = entity.hasRoles {
            hasRoles = (roles.allObjects as? [Role])?.compactMap { RoleCodable(managedObject: $0, context: context) } ?? []
        }
        if let contractLedgers = entity.hasContractLedgers {
            hasContractLedgers = (contractLedgers.allObjects as? [ContractLedger])?.compactMap { ContractLedgerCodable(managedObject: $0, context: context) } ?? []
        }
    }
    
    func getManagedObjectFrom(_ context: NSManagedObjectContext) -> NSManagedObject {
        
        if let entity: Organization = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity, context: context)
            return entity
        } else {
            let entity: Organization = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity, context: context)
            return entity
        }
    }
    
    private func setPropertiesTo(_ entity: Organization, context: NSManagedObjectContext) {
        entity.id = id
        entity.userUID = userUID
        entity.title = title
        entity.createdAt = createdAt.nsDate
        entity.updatedAt = updatedAt?.nsDate
        entity.deleteDate = deleteDate?.nsDate
        entity.rootDeleteDate = rootDeleteDate?.nsDate
        
        entity.hasRoles = NSSet(array: hasRoles.compactMap { $0.getManagedObjectFrom(context) as? Role })
        entity.hasContractLedgers = NSSet(array: hasContractLedgers.compactMap { $0.getManagedObjectFrom(context) as? ContractLedger })
    }
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date().localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
    var hasRoles: [RoleCodable] = []
    var hasContractLedgers: [ContractLedgerCodable] = []
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case hasRoles = "roles"
        case hasContractLedgers = "contractLedgers"
        case name
    }
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
        
        let createdAtInt = try container.decode(Int64.self, forKey: .createdAt)
        let updatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .updatedAt)
        let deletedAtInt = try container.decodeIfPresent(Int64.self, forKey: .deleteDate)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt) / 1000)
        
        if let updatedAtInt = updatedAtInt {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt) / 1000)
        }
        if let deletedAtInt = deletedAtInt {
            deleteDate = Date(timeIntervalSince1970: TimeInterval(deletedAtInt) / 1000)
        }
        if let rootdeleteDateInt = try container.decodeIfPresent(Int.self, forKey: .rootDeleteDate) {
            rootDeleteDate = Date(timeIntervalSince1970: TimeInterval(rootdeleteDateInt))
        }
        
        self.hasRoles = try (container.decodeIfPresent([RoleCodable].self, forKey: .hasRoles) ?? [])
        self.hasContractLedgers = try container.decodeIfPresent([ContractLedgerCodable].self, forKey: .hasContractLedgers) ?? []
        
        self.title = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        try container.encode(userUID, forKey: .userUID)

       try container.encode((createdAt as Date).intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
            try container.encode((updatedAt as Date).intValue, forKey: .updatedAt)
        } else {
            try container.encode((createdAt as Date).intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
            try container.encode((deleteDate as Date).intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
        
        try container.encode(hasRoles, forKey: .hasRoles)
        try container.encode(hasContractLedgers, forKey: .hasContractLedgers)
        try container.encode(title, forKey: .name)
    }
}