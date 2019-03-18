//
//  Instrument.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


import Foundation
import CoreData


public class Instrument: Entity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<Instrument> {
		return NSFetchRequest<Instrument>(entityName: "Instrument")
	}
	
	@NSManaged public var isLoop: Bool
	@NSManaged public var resourcePath: String?
	@NSManaged public var typeString: String?
	@NSManaged public var resourcePathAWS: String?
	@NSManaged public var hasCluster: Cluster?
	
	
	enum CodingKeysInstrument:String,CodingKey
	{
		case isLoop
		case resourcePath
		case typeString
		case resourcePathAWS
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysInstrument.self)
		
		try container.encode(isLoop, forKey: .isLoop)
		try container.encode(resourcePath, forKey: .resourcePath)
		try container.encode(typeString, forKey: .typeString)
		try container.encode(resourcePathAWS, forKey: .resourcePathAWS)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Instrument", in: managedObjectContext) else {
			fatalError("failed at Instrument")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		//		try self.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeysInstrument.self)

		isLoop = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isLoop) ?? 0) as NSNumber)
		resourcePath = try container.decodeIfPresent(String.self, forKey: .resourcePath)
		typeString = try container.decodeIfPresent(String.self, forKey: .typeString)
		resourcePathAWS = try container.decodeIfPresent(String.self, forKey: .resourcePathAWS)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreInstrument.createEntityNOTsave()
		for key in self.entity.propertiesByName.keys {
			if key != "id" {
				let value: Any? = self.value(forKey: key)
				entity.setValue(value, forKey: key)
			}
		}
		deleteDate = Date() as NSDate
		return entity
	}
	
	
	
}
