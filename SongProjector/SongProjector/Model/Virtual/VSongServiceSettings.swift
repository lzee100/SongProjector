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
	
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VSongServiceSettings] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreSongServiceSettings.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreSongServiceSettings.getEntities().map({ VSongServiceSettings(songserviceSettings: $0) })
	}
	
	class func single(with id: Int64?) -> VSongServiceSettings? {
		if let id = id, let songserviceSettings = CoreSongServiceSettings.getEntitieWith(id: id) {
			return VSongServiceSettings(songserviceSettings: songserviceSettings)
		}
		return nil
	}
	
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
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let songserviceSettings = entity as? SongServiceSettings {
			songserviceSettings.hasSongServiceSections = NSSet(array: sections.map({ $0.getManagedObject(context: context) }))
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let songserviceSettings = entity as? SongServiceSettings {
			sections = (songserviceSettings.hasSongServiceSections?.allObjects as? [SongServiceSection] ?? []).map({ VSongServiceSection(entity: $0) }).sorted(by: { $0.position < $1.position })
		}
	}
	
	convenience init(songserviceSettings: SongServiceSettings) {
		self.init()
		getPropertiesFrom(entity: songserviceSettings)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreSongServiceSettings.managedObjectContext = context
		if let storedEntity = CoreSongServiceSettings.getEntitieWith(id: id) {
			CoreSongServiceSettings.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreSongServiceSettings.managedObjectContext = context
			let newEntity = CoreSongServiceSettings.createEntityNOTsave()
			CoreSongServiceSettings.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
	
}
