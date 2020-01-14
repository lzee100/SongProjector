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
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VContractLedger] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreContractLedger.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreContractLedger.getEntities().map({ VContractLedger(contractLedger: $0) })
	}
	
	class func single(with id: Int64?) -> VContractLedger? {
		if let id = id, let contractLedger = CoreContractLedger.getEntitieWith(id: id) {
			return VContractLedger(contractLedger: contractLedger)
		}
		return nil
	}

	
	var contractId: Int64 = 0
	var organizationId: Int64 = 0
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
	
	var hasOrganization: Organization? {
		return CoreOrganization.getEntitieWith(id: organizationId)
	}
	var hasContract: Contract? {
		return CoreContract.getEntitieWith(id: contractId)
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
				
		contractId = try container.decodeIfPresent(Int64.self, forKey: .contractId) ?? 0
		organizationId = try container.decodeIfPresent(Int64.self, forKey: .organizationId) ?? 0
		
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
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let contractLedger = entity as? ContractLedger {
			contractId = contractLedger.contractId
			organizationId = contractLedger.organizationId
			userName = contractLedger.userName
			phoneNumber = contractLedger.phoneNumber
			hasApplePay = contractLedger.hasApplePay
		}
	}
	
	convenience init(contractLedger: ContractLedger) {
		self.init()
		getPropertiesFrom(entity: contractLedger)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreContractLedger.managedObjectContext = context
		if let storedEntity = CoreContractLedger.getEntitieWith(id: id) {
			CoreContractLedger.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreContractLedger.managedObjectContext = context
			let newEntity = CoreContractLedger.createEntityNOTsave()
			CoreContractLedger.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
	
}
