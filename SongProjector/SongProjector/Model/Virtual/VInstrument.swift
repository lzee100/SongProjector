//
//  VInstrument.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VInstrument: VEntity {
	
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VInstrument] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreInstrument.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreInstrument.getEntities().map({ VInstrument(instrument: $0) })
	}
	
	class func single(with id: Int64?) -> VInstrument? {
		if let id = id, let instrument = CoreInstrument.getEntitieWith(id: id) {
			return VInstrument(instrument: instrument)
		}
		return nil
	}
	
	var isLoop: Bool = false
	var resourcePath: String? = nil
	var typeString: String? =  nil
	var type: InstrumentType? {
		return InstrumentType(typeString)
	}
	var resourcePathAWS: String? = nil
	var hasCluster: VCluster? = nil
	
	
	enum CodingKeysInstrument:String,CodingKey
	{
		case isLoop
		case resourcePath
		case typeString = "type"
		case resourcePathAWS
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysInstrument.self)
		
		try container.encode(isLoop, forKey: .isLoop)
		try container.encode(typeString, forKey: .typeString)
		try container.encode(resourcePathAWS, forKey: .resourcePathAWS)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
	
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysInstrument.self)

		isLoop = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isLoop) ?? 0) as NSNumber)
		typeString = try container.decodeIfPresent(String.self, forKey: .typeString)
		resourcePathAWS = try container.decodeIfPresent(String.self, forKey: .resourcePathAWS)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = VInstrument()
		copy.isLoop = isLoop
		copy.resourcePath = resourcePath
		copy.typeString = typeString
		copy.resourcePathAWS = resourcePath
		copy.hasCluster = hasCluster?.copy() as? VCluster
		return copy
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let instrument = entity as? Instrument {
			instrument.isLoop = self.isLoop
			instrument.resourcePath = self.resourcePath
			instrument.typeString = self.typeString
			instrument.resourcePathAWS = self.resourcePathAWS
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let instrument = entity as? Instrument {
			isLoop = instrument.isLoop
			resourcePath = instrument.resourcePath
			typeString = instrument.typeString
			resourcePathAWS = instrument.resourcePathAWS
		}
	}
	
	convenience init(instrument: Instrument) {
		self.init()
		getPropertiesFrom(entity: instrument)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreInstrument.managedObjectContext = context
		if let storedEntity = CoreInstrument.getEntitieWith(id: id) {
			CoreInstrument.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreInstrument.managedObjectContext = context
			let newEntity = CoreInstrument.createEntityNOTsave()
			CoreInstrument.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
}
