//
//  ContractLedgerCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct ContractLedgerCodable: EntityCodableType {
        
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
    var contractId: String = UUID().uuidString
    var organizationId: String = UUID().uuidString
    var userName: String = ""
    var phoneNumber: String = ""
    var hasApplePay: Bool = false
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case contractId = "contract_id"
        case organizationId = "organization_id"
        case userName
        case phoneNumber
        case hasApplePay
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
        
        
        contractId = try container.decodeIfPresent(String.self, forKey: .contractId) ?? ""
        organizationId = try container.decodeIfPresent(String.self, forKey: .organizationId) ?? ""
        
        userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        if let hasApplePay = try container.decodeIfPresent(Int.self, forKey: .hasApplePay) {
            self.hasApplePay = Bool(truncating: NSNumber(integerLiteral: hasApplePay))
        } else {
            hasApplePay = false
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
        
        try container.encode(contractId, forKey: .contractId)
        try container.encode(organizationId, forKey: .organizationId)
        try container.encode(userName, forKey: .userName)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(hasApplePay, forKey: .hasApplePay)
    }
}

extension ContractLedgerCodable: FileTransferable {
    
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
