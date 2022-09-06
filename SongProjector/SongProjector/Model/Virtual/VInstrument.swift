//
//  VInstrument.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class VInstrument: VEntity {
	
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
        case id
		case isLoop
		case resourcePath
		case typeString = "type"
		case resourcePathAWS
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysInstrument.self)
		
        try container.encode(id, forKey: .id)
        try container.encode(Int(truncating: NSNumber(value: isLoop)), forKey: .isLoop)
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
			instrument.isLoop = isLoop
			instrument.resourcePath = resourcePath
			instrument.typeString = typeString
            instrument.resourcePath = resourcePath
			instrument.resourcePathAWS = resourcePathAWS
		}
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
		super.getPropertiesFrom(entity: entity, context: context)
		if let instrument = entity as? Instrument {
			isLoop = instrument.isLoop
			resourcePath = instrument.resourcePath
			typeString = instrument.typeString
            resourcePath = instrument.resourcePath
			resourcePathAWS = instrument.resourcePathAWS
		}
	}
	
    convenience init(instrument: Instrument, context: NSManagedObjectContext) {
		self.init()
        getPropertiesFrom(entity: instrument, context: context)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: Instrument = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Instrument = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
	}
	
}

extension VInstrument {
    var image: UIImage? {
        guard let type = type else {
            return nil
        }
        switch type {
        case .guitar, .piano, .drums: return UIImage(named: type.rawValue.capitalized)
        case .bassGuitar: return UIImage(named: "BassGuitar")
        case .pianoSolo: return UIImage(named: "Piano")
        case .unKnown: return nil
        }
    }
}
