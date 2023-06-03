//
//  UniversalUpdatedAtCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct UniversalUpdatedAtCodable: EntityCodableType, Codable {
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
    var universalUpdatedAt: Date?
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case universalUpdatedAt
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
        
        if let universalUpdatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .universalUpdatedAt) {
            universalUpdatedAt = Date(timeIntervalSince1970: TimeInterval(universalUpdatedAtInt) / 1000)
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
        
        if let upAt = universalUpdatedAt {
            try container.encode(upAt.intValue, forKey: .universalUpdatedAt)
        }
    }
}
