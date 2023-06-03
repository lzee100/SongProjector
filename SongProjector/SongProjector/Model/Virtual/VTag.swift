//
//  VTag.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VTag: VEntity {
	    
	var position: Int16 = 0
    var isDeletable = true
	var hasSongServiceSections: [VSongServiceSection] = []
    
	enum CodingKeysTag: String, CodingKey {
		case position
        case id
        case isDeletable
	}
		
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTag.self)
		try container.encode(position, forKey: .position)
        try container.encode(id, forKey: .id)
        try container.encode(Int(truncating: NSNumber(value: isDeletable)), forKey: .isDeletable)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysTag.self)
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
        isDeletable = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isDeletable) ?? 0) as NSNumber)

		try super.initialization(decoder: decoder)
		
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let tag = entity as? Tag {
			tag.position = position
            tag.isDeletable = isDeletable
		}

	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let tag = entity as? Tag {
			position = tag.position
            isDeletable = tag.isDeletable
		}
	}
	
	convenience init(tag: Tag, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: tag, context: context)
	}
	
}
