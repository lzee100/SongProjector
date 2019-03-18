//
//  ContractLedger.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class ContractLedger: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ContractLedger> {
		return NSFetchRequest<ContractLedger>(entityName: "ContractLedger")
	}
	
	@NSManaged public var contractId: Int64
	@NSManaged public var organizationId: Int64
	@NSManaged public var userName: String
	@NSManaged public var phoneNumber: String
	@NSManaged public var hasApplePay: Bool

	
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
	
	
	
	// MARK: - Init
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
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
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "ContractLedger", in: managedObjectContext) else {
			fatalError("failed at ContractLedger")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
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
	
	
	
}
