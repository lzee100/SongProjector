//
//  VSongServiceSettings.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VSongServiceSettings: VEntity {
	
	var sections: [VSongServiceSection] = []
	
	enum CodingKeysSongServiceSettings: String, CodingKey
	{
		case sections
	}
	
	
	// MARK: - Init
	
	public override func initialization(decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSettings.self)
		sections = try (container.decodeIfPresent([VSongServiceSection].self, forKey: .sections) ?? []).sorted(by: { $0.position < $1.position })
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSongServiceSettings.self)
		try container.encode(sections, forKey: .sections)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSettings.self)
		sections = try (container.decodeIfPresent([VSongServiceSection].self, forKey: .sections) ?? []).sorted(by: { $0.position < $1.position })
		try super.initialization(decoder: decoder)
		
	}
	
//	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
//		super.setPropertiesTo(entity: entity, context: context)
//		if let songserviceSettings = entity as? SongServiceSettings {
//            sections.forEach({ _ = $0.getManagedObject(context: context) })
//            songserviceSettings.sectionIds = sections.map({ $0.id }).joined(separator: ",")
//		}
//	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let songserviceSettings = entity as? SongServiceSettings {
            sections = songserviceSettings.hasSections(moc: moc).map({ VSongServiceSection(songServiceSection: $0, context: context) })
		}
	}
	
    convenience init(songserviceSettings: SongServiceSettings, context: NSManagedObjectContext) {
		self.init()
        getPropertiesFrom(entity: songserviceSettings, context: context)
	}
	
//    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
//        if let entity: SongServiceSettings = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        } else {
//            let entity: SongServiceSettings = DataFetcher().createEntity(moc: context)
//            setPropertiesTo(entity: entity, context: context)
//            return entity
//        }
//    }

	
}
