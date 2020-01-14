//
//  VContract.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

class VContract: VEntity {
	
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VContract] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreContract.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreContract.getEntities().map({ VContract(contract: $0) })
	}
	
	class func single(with id: Int64?) -> VContract? {
		if let id = id, let contract = CoreContract.getEntitieWith(id: id) {
			return VContract(contract: contract)
		}
		return nil
	}
	
	var name: String = ""
	var buttonContent: String = ""
	
	
	enum CodingKeysContract: String, CodingKey
	{
		case id
		case name
		case button
		case hasContractFeatures = "features"
	}
	
		
	// MARK: - Encodable
	
	override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysContract.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encode(buttonContent, forKey: .button)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysContract.self)
		id = try container.decode(Int64.self, forKey: .id)
		name = try container.decode(String.self, forKey: .name)
		buttonContent = try container.decode(String.self, forKey: .button)
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let contract = entity as? Contract {
			contract.name = self.name
			contract.buttonContent = self.buttonContent
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let contract = entity as? Contract {
			name = contract.name
			buttonContent = contract.buttonContent
		}
	}
	
	convenience init(contract: Contract) {
		self.init()
		getPropertiesFrom(entity: contract)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreContract.managedObjectContext = context
		if let storedEntity = CoreContract.getEntitieWith(id: id) {
			CoreContract.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreContract.managedObjectContext = context
			let newEntity = CoreContract.createEntityNOTsave()
			CoreContract.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}

}
