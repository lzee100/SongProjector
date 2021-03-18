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
		id = try container.decode(String.self, forKey: .id)
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
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let contract = entity as? Contract {
			name = contract.name
			buttonContent = contract.buttonContent
		}
	}
	
    convenience init(contract: Contract, context: NSManagedObjectContext) {
		self.init()
        getPropertiesFrom(entity: contract, context: context)
	}
	
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: Contract = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Contract = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

}
