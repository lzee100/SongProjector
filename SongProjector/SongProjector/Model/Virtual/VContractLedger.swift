//
//  VContractLedger.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VContractLedger: VEntity {
		
    var contractId: String = UUID().uuidString
	var organizationId: String = UUID().uuidString
	var userName: String = ""
	var phoneNumber: String = ""
	var hasApplePay: Bool = false

	
	enum CodingKeysContractLedger:String,CodingKey
	{
		case contractId = "contract_id"
		case organizationId = "organization_id"
		case userName
		case phoneNumber
		case hasApplePay

	}
	
    func hasOrganization(moc: NSManagedObjectContext) -> Organization? {
        return nil
//        let org: Organization? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: organizationId)])
//        return org
    }
    func hasContract(moc: NSManagedObjectContext) -> Contract? {
        return nil
//        let contract: Contract? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: contractId)])
//        return contract
    }
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysContractLedger.self)
		
		try container.encode(contractId, forKey: .contractId)
		try container.encode(organizationId, forKey: .organizationId)
		try container.encode(userName, forKey: .userName)
		try container.encode(phoneNumber, forKey: .phoneNumber)
		try container.encode(hasApplePay, forKey: .hasApplePay)
		
		try super.encode(to: encoder)
		
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysContractLedger.self)
				
		contractId = try container.decodeIfPresent(String.self, forKey: .contractId) ?? ""
		organizationId = try container.decodeIfPresent(String.self, forKey: .organizationId) ?? ""
		
		userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
		phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
		if let hasApplePay = try container.decodeIfPresent(Int.self, forKey: .hasApplePay) {
			self.hasApplePay = Bool(truncating: NSNumber(integerLiteral: hasApplePay))
		} else {
			hasApplePay = false
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let contractLedger = entity as? ContractLedger {
			contractLedger.contractId = self.contractId
			contractLedger.organizationId = self.organizationId
			contractLedger.userName = self.userName
			contractLedger.phoneNumber = self.phoneNumber
			contractLedger.hasApplePay = self.hasApplePay
		}
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let contractLedger = entity as? ContractLedger {
			contractId = contractLedger.contractId
			organizationId = contractLedger.organizationId
			userName = contractLedger.userName
			phoneNumber = contractLedger.phoneNumber
			hasApplePay = contractLedger.hasApplePay
		}
	}
	
    convenience init(contractLedger: ContractLedger, context: NSManagedObjectContext) {
		self.init()
        getPropertiesFrom(entity: contractLedger, context: context)
	}
	
//    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
//        if let entity: ContractLedger = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        } else {
//            let entity: ContractLedger = DataFetcher().createEntity(moc: context)
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        }
//    }

}
