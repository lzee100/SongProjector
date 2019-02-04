//
//  Cluster.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

@objc(Cluster)
public class Cluster: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Cluster> {
		return NSFetchRequest<Cluster>(entityName: "Cluster")
	}
	
	@NSManaged public var tagId: Int64
	@NSManaged public var isLoop: Bool
	@NSManaged public var position: Int16
	@NSManaged public var time: Double
	@NSManaged public var hasTag: Tag?
	
	@NSManaged public var hasInstruments: NSSet?
	@NSManaged public var hasSheets: NSSet?
	
	private var clusterSheets: [SheetMetaType] {
		if let hasSheets = hasSheets?.allObjects as? [SheetMetaType] {
			return hasSheets
		}
		return []
	}

	
	enum CodingKeysCluster:String,CodingKey
	{
		case isLoop
		case position
		case time
		case tagId = "tag"
		case hasSheets = "sheets"
		case hasInstruments = "instruments"
	}
	
	
	
	// MARK: - Init
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysCluster.self)
		try container.encode(Int(truncating: NSNumber(value: isLoop)), forKey: .isLoop)
		try container.encode(position, forKey: .position)
		try container.encode(time, forKey: .time)
		try container.encode(tagId, forKey: .tagId)
		try container.encode(clusterSheets.map(AnySheet.init), forKey: .hasSheets)
		try container.encode(hasInstrumentsArray, forKey: .hasInstruments)

		try super.encode(to: encoder)
		
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Cluster", in: managedObjectContext) else {
			fatalError("failed at Cluster")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysCluster.self)
		isLoop = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isLoop) ?? 0) as NSNumber)
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
		time = try container.decodeIfPresent(Double.self, forKey: .time) ?? 0
		tagId = try container.decode(Int64.self, forKey: .tagId)
		
		hasSheets = try NSSet(array: container.decode([AnySheet].self, forKey: .hasSheets).map { $0.base })
		let instr = try container.decodeIfPresent([Instrument].self, forKey: .hasInstruments)
		if let instr = instr {
			hasInstruments = NSSet(array: instr)
		}

		try super.initialization(decoder: decoder)
		
	}
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreCluster.createEntityNOTsave()
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

// MARK: Generated accessors for hasInstruments
extension Cluster {
	
	@objc(addHasInstrumentsObject:)
	@NSManaged public func addToHasInstruments(_ value: Instrument)
	
	@objc(removeHasInstrumentsObject:)
	@NSManaged public func removeFromHasInstruments(_ value: Instrument)
	
	@objc(addHasInstruments:)
	@NSManaged public func addToHasInstruments(_ values: NSSet)
	
	@objc(removeHasInstruments:)
	@NSManaged public func removeFromHasInstruments(_ values: NSSet)
	
}

// MARK: Generated accessors for hasSheets
extension Cluster {
	
	@objc(addHasSheetsObject:)
	@NSManaged public func addToHasSheets(_ value: Sheet)
	
	@objc(removeHasSheetsObject:)
	@NSManaged public func removeFromHasSheets(_ value: Sheet)
	
	@objc(addHasSheets:)
	@NSManaged public func addToHasSheets(_ values: NSSet)
	
	@objc(removeHasSheets:)
	@NSManaged public func removeFromHasSheets(_ values: NSSet)
	
}
