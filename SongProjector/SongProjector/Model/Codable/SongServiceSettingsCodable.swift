//
//  SongServiceSettingsCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct SongServiceSettingsCodable: EntityCodableType, Identifiable {
    
    static func makeDefault(userUID: String? = nil) -> SongServiceSettingsCodable? {
#if DEBUG
        let userId = "userid"
#else
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
#endif
        
        return SongServiceSettingsCodable(userUID: userUID ?? userId)
    }
    
    public var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
    var sections: [SongServiceSectionCodable] = []
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case sections
    }
    
    init(
        id: String = "CHURCHBEAM" + UUID().uuidString,
        userUID: String = "",
        title: String? = nil,
        createdAt: Date = Date.localDate(),
        updatedAt: Date? = nil,
        deleteDate: Date? = nil,
        isTemp: Bool = false,
        rootDeleteDate: Date? = nil,
        sections: [SongServiceSectionCodable] = []
    ) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.isTemp = isTemp
        self.rootDeleteDate = rootDeleteDate
        self.sections = sections
    }
    
    init(entity: SongServiceSettings) {
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
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
        
        sections = try (container.decodeIfPresent([SongServiceSectionCodable].self, forKey: .sections) ?? []).sorted(by: { $0.position < $1.position })
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
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
        
        try container.encode(sections, forKey: .sections)
    }
}

extension SongServiceSettingsCodable: FileTransferable {
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
    }
    
    func getDeleteObjects(forceDelete: Bool) -> [DeleteObject] {
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
        modifiedDocument.updatedAt = Date.localDate()
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
