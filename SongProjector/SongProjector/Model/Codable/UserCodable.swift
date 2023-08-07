//
//  UserCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct UserCodable: FileTransferable, Codable {
    
    init?(entity: User) {
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
    }

    private let productExpireDateKey = "churchbeamProductExpireDateKey"
    private let productIdKey = "churchbeamProductIdKey"
    private let productPilotDateKey = "productPilotDateKey"
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
    var appInstallTokens: [String] = []
    var sheetTimeOffset: Double = 0
    var adminCode: String? = nil
    var adminInstallTokenId: String? = nil
    var googleCalendarId: String? = nil
    
    var productId: String? {
        set {
            if let id = newValue {
                KeychainService.updateItem(id, serviceKey: productIdKey)
            } else {
                KeychainService.removeItem(serviceKey: productIdKey)
            }
        }
        get {
            return KeychainService.loadItem(serviceKey: productIdKey)
        }
    }
    
    var productExpireDate: Date? {
        set {
            if let date = newValue {
                KeychainService.updateItem(date.intValue.stringValue, serviceKey: productExpireDateKey)
            } else {
                KeychainService.removeItem(serviceKey: productExpireDateKey)
            }
        }
        get {
            if let item = KeychainService.loadItem(serviceKey: productExpireDateKey), let time = Int64(item) {
                return Date(timeIntervalSince1970: TimeInterval(time) / 1000)
            }
            return nil
        }
    }
    
    var pilotStartDate: Date? {
        set {
            if let date = newValue {
                KeychainService.updateItem(date.intValue.stringValue, serviceKey: productPilotDateKey)
            } else {
                KeychainService.removeItem(serviceKey: productPilotDateKey)
            }
        }
        get {
            if let item = KeychainService.loadItem(serviceKey: productPilotDateKey), let time = Int64(item) {
                return Date(timeIntervalSince1970: TimeInterval(time) / 1000)
            }
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case appInstallTokens
        case contractType
        case pilotStartDate
        case sheetTimeOffset
        case adminCode
        case adminInstallTokenId
        case googleCalendarId
        case productExpireDate
        case productId
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
        
        let installTokens = try container.decodeIfPresent(String.self, forKey: .appInstallTokens) ?? ""
        appInstallTokens = installTokens.split(separator: ",").compactMap({ String($0) })
        if let sheetTimeOffsetString = try container.decodeIfPresent(Int.self, forKey: .sheetTimeOffset) {
            sheetTimeOffset = Double(sheetTimeOffsetString)
        }
        if let pilotStartDateInt = try container.decodeIfPresent(Int64.self, forKey: .pilotStartDate) {
            pilotStartDate = Date(timeIntervalSince1970: TimeInterval(pilotStartDateInt) / 1000)
        }
        if let productExpireDateInt = try container.decodeIfPresent(Int64.self, forKey: .productExpireDate) {
            productExpireDate = Date(timeIntervalSince1970: TimeInterval(productExpireDateInt) / 1000)
        }

        adminCode = try container.decodeIfPresent(String.self, forKey: .adminCode)
        adminInstallTokenId = try container.decodeIfPresent(String.self, forKey: .adminInstallTokenId)
        googleCalendarId = try container.decodeIfPresent(String.self, forKey: .googleCalendarId)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
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
        
        try container.encode(appInstallTokens.joined(separator: ","), forKey: .appInstallTokens)
        try container.encode("\(sheetTimeOffset)", forKey: .sheetTimeOffset)
        if let pilotStartDate = pilotStartDate {
            try container.encode(pilotStartDate.intValue, forKey: .pilotStartDate)
        }
        try container.encode(adminCode, forKey: .adminCode)
        try container.encode(adminInstallTokenId, forKey: .adminInstallTokenId)
        try container.encode(googleCalendarId, forKey: .googleCalendarId)
        try container.encode(productId, forKey: .productId)
        try container.encode(productExpireDate?.intValue ?? 0, forKey: .productExpireDate)
    }
    
    var transferObjects: [TransferObject] = []
    
    var uploadObjects: [TransferObject] = []
    
    var downloadObjects: [TransferObject] = []
    
    mutating func setTransferObjects(_ transferObjects: [TransferObject]) throws {
        
    }
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
        
    }
    
    func getDeleteObjects(forceDelete: Bool) -> [DeleteObject] {
        []
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
