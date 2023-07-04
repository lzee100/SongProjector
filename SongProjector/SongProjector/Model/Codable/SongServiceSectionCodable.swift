//
//  SongServiceSectionCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData
import CoreData

public struct SongServiceSectionCodable: EntityCodableType, Codable, Identifiable {
    
    static func makeDefault(title: String, position: Int, numberOfSongs: Int, tags: [TagCodable], pinnableTags: [PinnableTagCodable]) -> SongServiceSectionCodable? {
#if DEBUG
        let userId = "userid"
#else
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
#endif
        
        return SongServiceSectionCodable(userUID: userId, title: title, position: position, numberOfSongs: numberOfSongs, tags: tags, pinnableTags: pinnableTags)
    }
    
    public var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
    var position: Int16 = 0
    var numberOfSongs: Int16 = 0
    var tagIds: [String] = []
    var tags: [TagCodable] = []
    var pinnableTags: [PinnableTagCodable] = []

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
        case numberOfSongs
        case tags
        case pinnableTags
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
        position: Int,
        numberOfSongs: Int,
        tags: [TagCodable],
        pinnableTags: [PinnableTagCodable]
    ) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.isTemp = isTemp
        self.rootDeleteDate = rootDeleteDate
        self.position = Int16(position)
        self.numberOfSongs = Int16(numberOfSongs)
        self.tags = tags
        self.pinnableTags = pinnableTags
    }
    
    init(entity: SongServiceSection) {
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
        
        position = entity.position
        numberOfSongs = entity.numberOfSongs
        tagIds = entity.tagIds.split(separator: ",").map(String.init)
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
        
        position = try container.decode(Int16.self, forKey: .position)
        numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
        tags = try container.decodeIfPresent([TagCodable].self, forKey: .tags) ?? []
        tagIds = tags.compactMap({ $0.id })
        
        pinnableTags = try container.decodeIfPresent([PinnableTagCodable].self, forKey: .pinnableTags) ?? []
        if pinnableTags.count > 0 {
            tagIds = pinnableTags.compactMap({ $0.id })
        }
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
        
        try container.encode(position, forKey: .position)
        try container.encode(numberOfSongs, forKey: .numberOfSongs)
        try container.encode(tags, forKey: .tags)
        
        if pinnableTags.count > 0 {
            try container.encode(pinnableTags, forKey: .pinnableTags)
        }
    }
}

extension SongServiceSectionCodable: FileTransferable {
    
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
