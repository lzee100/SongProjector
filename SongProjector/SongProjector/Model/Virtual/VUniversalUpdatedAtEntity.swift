//
//  VUniversalUpdatedAtEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData
import Firebase

public struct VUniversalUpdatedAt: VEntityType, Codable {
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
    
    var universalUpdatedAt: Date?


    enum CodingKeysUniversalUpdatedAtEntity: String, CodingKey {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case universalUpdatedAt
    }
    
    init?() {
        id = "CHURCHBEAM" + UUID().uuidString
        title = nil
        guard let userUID = Auth.auth().currentUser?.uid else {
            return nil
        }
        self.userUID = userUID
        createdAt = Date().localDate().nsDate
        updatedAt = nil
        deleteDate = nil
        rootDeleteDate = nil
        
        universalUpdatedAt = nil
    }

    init(_ entity: UniversalUpdatedAtEntity) {
        self.id = entity.id
        self.userUID = entity.userUID
        self.title = entity.title
        self.createdAt = entity.createdAt
        self.updatedAt = entity.updatedAt
        self.deleteDate = entity.deleteDate
        self.rootDeleteDate = entity.rootDeleteDate?.date
        
        self.universalUpdatedAt = entity.universalUpdatedAt?.date
    }
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysUniversalUpdatedAtEntity.self)
                
        try container.encode(id, forKey: .id)
        try container.encode(userUID, forKey: .userUID)
        try container.encode((createdAt as Date).intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
            //            let updatedAtString = GlobalDateFormatter.localToUTCNumber(date: updatedAt as Date)
            try container.encode((updatedAt as Date).intValue, forKey: .updatedAt)
        } else {
            try container.encode((createdAt as Date).intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
            //            let deleteDateString = GlobalDateFormatter.localToUTCNumber(date: deleteDate as Date)
            try container.encode((deleteDate as Date).intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
        
        if let upAt = universalUpdatedAt {
            try container.encode(upAt.intValue, forKey: .universalUpdatedAt)
        }
    }
    
    
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeysUniversalUpdatedAtEntity.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
        let createdAtInt = try container.decode(Int64.self, forKey: .createdAt)
        let updatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .updatedAt)
        let deletedAtInt = try container.decodeIfPresent(Int64.self, forKey: .deleteDate)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt) / 1000) as NSDate
        
        if let updatedAtInt = updatedAtInt {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt) / 1000) as NSDate
        } else {
            updatedAt = nil
        }
        if let deletedAtInt = deletedAtInt {
            deleteDate = Date(timeIntervalSince1970: TimeInterval(deletedAtInt) / 1000) as NSDate
        } else {
            deleteDate = nil
        }
        if let rootdeleteDateInt = try container.decodeIfPresent(Int.self, forKey: .rootDeleteDate) {
            rootDeleteDate = Date(timeIntervalSince1970: TimeInterval(rootdeleteDateInt / 1000))
        } else {
            rootDeleteDate = nil
        }

        if let universalUpdatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .universalUpdatedAt) {
            universalUpdatedAt = Date(timeIntervalSince1970: TimeInterval(universalUpdatedAtInt) / 1000)
        }
    }
    
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            
            if let entity = entity as? UniversalUpdatedAtEntity {
                
                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                entity.universalUpdatedAt = universalUpdatedAt as NSDate?

            }
        }
        
        if let entity: UniversalUpdatedAtEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: UniversalUpdatedAtEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }
}
