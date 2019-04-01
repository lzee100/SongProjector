//
//  SongServiceSettings.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData


public class SongServiceSettings: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SongServiceSettings> {
		return NSFetchRequest<SongServiceSettings>(entityName: "SongServiceSettings")
	}
	
	@NSManaged public var hasSongServiceSections: NSSet?

	var sections: [SongServiceSection] {
		let sec = hasSongServiceSections?.allObjects as? [SongServiceSection] ?? []
		return sec.sorted(by: { $0.position > $1.position })
	}
	
	
	enum CodingKeysSongServiceSettings: String, CodingKey
	{
		case sections
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
		
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSettings.self)
		
		let sections = Entity.getEntities { () -> [SongServiceSection] in
			return try container.decodeIfPresent([SongServiceSection].self, forKey: .sections) ?? []
		}
		
		hasSongServiceSections = NSSet(array: sections)

		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSongServiceSettings.self)
		if let hasSongServiceSections = hasSongServiceSections?.allObjects as? [SongServiceSection] {
			try container.encode(hasSongServiceSections, forKey: .sections)
		}
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "SongServiceSettings", in: managedObjectContext) else {
			fatalError("failed at SongServiceSettings")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSettings.self)
		
		let sections = Entity.getEntities { () -> [SongServiceSection] in
			return try container.decodeIfPresent([SongServiceSection].self, forKey: .sections) ?? []
		}

		hasSongServiceSections = NSSet(array: sections)
		
		try super.initialization(decoder: decoder)
		
		sections.forEach({
			$0.hasSongServiceSettings = self
		})
		
	}
	
}


// MARK: Generated accessors for hasSongServiceSections
extension SongServiceSettings {
	
	@objc(addHasSongServiceSectionsObject:)
	@NSManaged public func addToHasSongServiceSections(_ value: SongServiceSection)
	
	@objc(removeHasSongServiceSectionsObject:)
	@NSManaged public func removeFromHasSongServiceSections(_ value: SongServiceSection)
	
	@objc(addHasSongServiceSections:)
	@NSManaged public func addToHasSongServiceSections(_ values: NSSet)
	
	@objc(removeHasSongServiceSections:)
	@NSManaged public func removeFromHasSongServiceSections(_ values: NSSet)
	
}

extension SongServiceSettings {
	
	var isValid: Bool {
		var valid = true
		if sections.count == 0 {
			return false
		}
		for section in sections {
			if section.title == nil || section.tags.count == 0 {
				valid = false
				break
			}
		}
		return valid
	}
}
