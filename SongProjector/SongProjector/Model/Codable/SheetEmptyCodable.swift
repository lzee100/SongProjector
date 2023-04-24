//
//  SheetEmptyCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct SheetEmptyCodable: EntityCodableType, SheetMetaType {    
    
    static func makeDefault() -> SheetEmptyCodable {
        
#if DEBUG
        let userId = "userid"
#else
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
#endif
        
        return SheetEmptyCodable(
            id: "CHURCHBEAM" + UUID().uuidString,
            userUID: userId,
            title: nil,
            createdAt: Date().localDate(),
            updatedAt: nil,
            deleteDate: nil,
            rootDeleteDate: nil,
            isEmptySheet: true,
            position: 0,
            time: 0.0,
            hasTheme: nil
        )
    }
    
    init?(managedObject: NSManagedObject, context: NSManagedObjectContext) {
        guard let entity = managedObject as? SheetEmptyEntity else { return nil }
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
        
        isEmptySheet = entity.isEmptySheet
        position = Int(entity.position)
        time = entity.time
        if let theme = entity.hasTheme {
            hasTheme = ThemeCodable(managedObject: theme, context: context)
        }
    }
    
    func getManagedObjectFrom(_ context: NSManagedObjectContext) -> NSManagedObject {
        
        if let entity: SheetEmptyEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity, context: context)
            return entity
        } else {
            let entity: SheetEmptyEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity, context: context)
            return entity
        }
    }
    
    private func setPropertiesTo(_ entity: SheetEmptyEntity, context: NSManagedObjectContext) {
        entity.id = id
        entity.userUID = userUID
        entity.title = title
        entity.createdAt = createdAt.nsDate
        entity.updatedAt = updatedAt?.nsDate
        entity.deleteDate = deleteDate?.nsDate
        entity.rootDeleteDate = rootDeleteDate?.nsDate
        
        entity.isEmptySheet = isEmptySheet
        entity.position = Int16(position)
        entity.time = time
        entity.hasTheme = hasTheme?.getManagedObjectFrom(context) as? Theme
    }

    
    static let type: SheetType = .SheetEmpty

    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date().localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var rootDeleteDate: Date? = nil
    
    var isEmptySheet = false
    var position: Int = 0
    var time: Double = 0
    var hasTheme: ThemeCodable? = nil
    
    enum CodingKeysTheme:String,CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case isEmptySheet
        case position
        case time
        case hasCluster = "cluster"
        case hasTheme = "theme"
    }
    
    init(
        id: String,
        userUID: String,
        title: String?,
        createdAt: Date,
        updatedAt: Date?,
        deleteDate: Date?,
        rootDeleteDate: Date?,
        isEmptySheet: Bool,
        position: Int,
        time: Double,
        hasTheme: ThemeCodable?
    ) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.rootDeleteDate = rootDeleteDate
        self.isEmptySheet = isEmptySheet
        self.position = position
        self.time = time
        self.hasTheme = hasTheme
    }
    

    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysTheme.self)
        isEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isEmptySheet) ?? 0) as NSNumber)
        position = Int(try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0)
        let sheetTimeString = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
        time = Double(sheetTimeString) ?? 0.0
        hasTheme = try container.decodeIfPresent(ThemeCodable.self, forKey: .hasTheme)
        
        id  = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
        
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
    }
    
    
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysTheme.self)
        try container.encode(Int(truncating: NSNumber(value: isEmptySheet)), forKey: .isEmptySheet)
        try container.encode(position, forKey: .position)
        try container.encode(id, forKey: .id)
        try container.encode(time.stringValue, forKey: .time)
        if hasTheme != nil {
            try container.encode(hasTheme, forKey: .hasTheme)
        }
        
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
    }
}

extension SheetEmptyCodable: FileTransferable {
    
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
