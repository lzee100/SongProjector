//
//  Contract.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class Contract: NSManagedObject, Codable {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Contract> {
		return NSFetchRequest<Contract>(entityName: "Contract")
	}
	
	@NSManaged public var id: Int64
	@NSManaged public var name: String
	@NSManaged public var buttonContent: String
	
	
	enum CodingKeysContract: String, CodingKey
	{
		case id
		case name
		case button
		case hasContractFeatures = "features"
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	
	
	// MARK: - Encodable
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysContract.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encode(buttonContent, forKey: .button)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Contract", in: managedObjectContext) else {
			fatalError("failed at Contract")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysContract.self)
		id = try container.decode(Int64.self, forKey: .id)
		name = try container.decode(String.self, forKey: .name)
		buttonContent = try container.decode(String.self, forKey: .button)
	}

}
