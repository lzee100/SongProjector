//
//  SheetActivityCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct SheetActivitiesCodable: EntityCodableType, SheetMetaType {
    
    static func makeDefault() -> SheetActivitiesCodable {
            
    #if DEBUG
            let userId = "userid"
    #else
            guard let userId = Auth.auth().currentUser?.uid else {
                return nil
            }
    #endif
            return SheetActivitiesCodable(
                id: "CHURCHBEAM" + UUID().uuidString,
                userUID: userId,
                title: "Google activities sheet",
                createdAt: Date().localDate(),
                updatedAt: nil,
                deleteDate: nil,
                rootDeleteDate: nil,
                hasGoogleActivities: []
            )
        }
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString,
         userUID: String,
         title: String? = nil,
         createdAt: Date = Date().localDate(),
         updatedAt: Date? = nil,
         deleteDate: Date? = nil,
         rootDeleteDate: Date? = nil,
         position: Int = 0,
         hasGoogleActivities: [GoogleActivityCodable] = []) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.rootDeleteDate = rootDeleteDate
        self.position = position
        self.hasGoogleActivities = hasGoogleActivities
    }

    
    init?(managedObject: NSManagedObject, context: NSManagedObjectContext) {
        guard let entity = managedObject as? SheetActivitiesEntity else { return nil }
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
        self.position = entity.position.intValue
        
        if let activities = entity.hasGoogleActivity {
            hasGoogleActivities = (activities.allObjects as? [GoogleActivity])?.compactMap { GoogleActivityCodable(managedObject: $0, context: context) } ?? []
        }
    }
    
    func getManagedObjectFrom(_ context: NSManagedObjectContext) -> NSManagedObject {
        
        if let entity: SheetActivitiesEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity, context: context)
            return entity
        } else {
            let entity: SheetActivitiesEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity, context: context)
            return entity
        }
    }
    
    private func setPropertiesTo(_ entity: SheetActivitiesEntity, context: NSManagedObjectContext) {
        entity.id = id
        entity.userUID = userUID
        entity.title = title
        entity.createdAt = createdAt.nsDate
        entity.updatedAt = updatedAt?.nsDate
        entity.deleteDate = deleteDate?.nsDate
        entity.rootDeleteDate = rootDeleteDate?.nsDate
        
        entity.hasGoogleActivity = NSSet(array: hasGoogleActivities.compactMap { $0.getManagedObjectFrom(context) as? GoogleActivity })
    }

    
    static let type: SheetType = .SheetActivities
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date().localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var rootDeleteDate: Date? = nil
    var position: Int
    var hasGoogleActivities: [GoogleActivityCodable] = []
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        case position
    }
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
        
        let createdAtInt = try container.decode(Int.self, forKey: .createdAt)
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
        if let position = try container.decodeIfPresent(Int.self, forKey: .position) {
            self.position = position
        } else {
            self.position = 0
        }
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
        try container.encode(position, forKey: .position)
    }
}

extension SheetActivitiesCodable: FileTransferable {
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
    }
    
    func getDeleteObjects(forceDelete: Bool) -> [String] {
        []
    }
    
    var uploadObjects: [TransferObject] {
        []
    }
    
    var downloadObjects: [TransferObject] {
        []
    }
    
    var transferObjects: [TransferObject] {
        uploadObjects + downloadObjects
    }
    
    mutating func setTransferObjects(_ transferObjects: [TransferObject]) throws {
    }
    
    func setDeleteDate() -> FileTransferable {
        var modifiedDocument = self
        if uploadSecret != nil {
            modifiedDocument.rootDeleteDate = Date()
        } else {
            modifiedDocument.deleteDate = Date()
        }
        return modifiedDocument
    }
    
    func setUpdatedAt() -> FileTransferable {
        var modifiedDocument = self
        modifiedDocument.updatedAt = Date()
        return modifiedDocument
    }
    
    func setUserUID() throws -> FileTransferable {
        var modifiedDocument = self
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        modifiedDocument.userUID = userUID
        return modifiedDocument
    }

}
