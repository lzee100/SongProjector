//
//  VContractLedger.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VContractLedger: VEntityType, Codable {
    
    let id: String
    let userUID: String
    let title: String?
    let createdAt: NSDate
    let updatedAt: NSDate?
    let deleteDate: NSDate?
    let rootDeleteDate: Date?
		
    var contractId: String = UUID().uuidString
	var organizationId: String = UUID().uuidString
	var userName: String = ""
	var phoneNumber: String = ""
	var hasApplePay: Bool = false

	
	enum CodingKeysContractLedger:String,CodingKey
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
	
    func hasOrganization(moc: NSManagedObjectContext) -> Organization? {
        let org: Organization? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: organizationId)])
        return org
    }
    func hasContract(moc: NSManagedObjectContext) -> Contract? {
        let contract: Contract? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: contractId)])
        return contract
    }
	
	
	// MARK: - Encodable
	
    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysContractLedger.self)
        
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
        
        try container.encode(eventDescription, forKey: .eventDescription)
        
        if let startDate = startDate {
            try container.encode((startDate as Date).intValue, forKey: .startDate)
        }
        if let endDate = endDate {
            try container.encode((endDate as Date).intValue, forKey: .endDate)
        }
		
		try container.encode(contractId, forKey: .contractId)
		try container.encode(organizationId, forKey: .organizationId)
		try container.encode(userName, forKey: .userName)
		try container.encode(phoneNumber, forKey: .phoneNumber)
		try container.encode(hasApplePay, forKey: .hasApplePay)
		
		try super.encode(to: encoder)
		
	}
	
	
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysContractLedger.self)
        
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
    
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let entity = entity as? ContractLedger {
                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                entity.contractId = self.contractId
                entity.organizationId = self.organizationId
                entity.userName = self.userName
                entity.phoneNumber = self.phoneNumber
                entity.hasApplePay = self.hasApplePay
            }
        }
        
        if let entity: ContractLedger = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: ContractLedger = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

}
