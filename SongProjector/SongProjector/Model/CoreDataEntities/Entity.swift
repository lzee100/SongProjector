//
//  Entity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Entity: NSManagedObject, Codable, NSCopying {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
		return NSFetchRequest<Entity>(entityName: "Entity")
	} 
	
	@NSManaged public var id: Int64
	@NSManaged public var title: String?
	@NSManaged public var createdAt: NSDate?
	@NSManaged public var updatedAt: NSDate?
	@NSManaged public var deleteDate: NSDate?
	@NSManaged public var isTemp: Bool

	
	enum CodingKeys: String, CodingKey
	{
		case id
		case title
		case createdAt
		case updatedAt
		case deleteDate = "deletedAt"
	}
		
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	
	
	
	// MARK: - Init
	
	public func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.id = try container.decode(Int64.self, forKey: .id)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		
		createdAt = try decodeDate(container: container, forKey: .createdAt) ?? NSDate()
		updatedAt = try decodeDate(container: container, forKey: .updatedAt) ?? NSDate()
		deleteDate = try decodeDate(container: container, forKey: .deleteDate)

	}
	
	required public convenience init(from decoder: Decoder) throws {

		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Entity", in: managedObjectContext) else {
				fatalError("failed at Entity")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.id = try container.decode(Int64.self, forKey: .id)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		
		createdAt = try decodeDate(container: container, forKey: .createdAt) ?? NSDate()
		updatedAt = try decodeDate(container: container, forKey: .updatedAt) ?? NSDate()
		deleteDate = try decodeDate(container: container, forKey: .deleteDate)
		isTemp = false
	}
	
	
	
	// MARK: - Encodable
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encode(title, forKey: .title)
		if let createdAt = createdAt {
			let createdAtString = GlobalDateFormatter.localToUTC(date: createdAt as Date)
			try container.encode(createdAtString, forKey: .createdAt)
		}
		if let updatedAt = updatedAt {
			let updatedAtString = GlobalDateFormatter.localToUTC(date: updatedAt as Date)
			try container.encode(updatedAtString, forKey: .createdAt)
		}
		if let deleteDate = deleteDate {
			let deleteDateString = GlobalDateFormatter.localToUTC(date: deleteDate as Date)
			try container.encode(deleteDateString, forKey: .deleteDate)
		}
	}
	
	
	public func copy(with zone: NSZone? = nil) -> Any {
		let entity = Entity()
		for key in self.entity.propertiesByName.keys {
			let value: Any? = self.value(forKey: key)
			entity.setValue(value, forKey: key)
		}
		deleteDate = Date() as NSDate
		isTemp = true
		return entity
	}
}

public extension CodingUserInfoKey {
	// Helper property to retrieve the Core Data managed object context
	static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

internal extension Entity {
	func decodeDate<T:CodingKey>(container: KeyedDecodingContainer<T>, forKey: T) throws -> NSDate? {
		let dateString = try container.decodeIfPresent(String.self, forKey: forKey)
		if let date = dateString, let localizedDate = GlobalDateFormatter.UTCToLocal(date: date) {
			return localizedDate as NSDate
		} else {
			return nil
		}
	}
}
