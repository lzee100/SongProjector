//
//VEntity.swift
//SongProjector
//
//Created by Leo van der Zee on 28/12/2019.
//Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class VEntity: NSObject, Codable {
	
	var id: Int64 = 0
	var title: String? = nil
	var createdAt: NSDate? = nil
	var updatedAt: NSDate? = nil
	var deleteDate: NSDate? = nil {
		didSet {
			didDeleteEntity()
		}
	}
	var isTemp: Bool = false
	let localId: String
	
	
	enum CodingKeys: String, CodingKey
	{
		case id
		case title
		case createdAt
		case updatedAt
		case deleteDate = "deletedAt"
	}
	
	override init() {
		localId = UUID().uuidString
		super.init()
	}
	
	
	// MARK: - Decodable
	
	public func initialization(decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
				
		self.id = try container.decode(Int64.self, forKey: .id)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		
		createdAt = try decodeDate(container: container, forKey: .createdAt) ?? NSDate()
		updatedAt = try decodeDate(container: container, forKey: .updatedAt) ?? NSDate()
		deleteDate = try decodeDate(container: container, forKey: .deleteDate)

	}
	
	required public convenience init(from decoder: Decoder) throws {

		self.init()
		
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
		try container.encodeIfPresent(title, forKey: .title)
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
	
	
	
	// MARK: - Copying
	
	public func copy(with zone: NSZone? = nil) -> Any {
		let copy = VEntity()
		copy.id = 0
		copy.title = title
		copy.createdAt = createdAt
		copy.updatedAt = updatedAt
		copy.deleteDate = Date() as NSDate
		copy.isTemp = true
		return copy
	}
	
	
	func getPropertiesFrom(entity: Entity) {
		id = entity.id
		title = entity.title
		createdAt = entity.createdAt
		updatedAt = entity.updatedAt
		deleteDate = entity.deleteDate
		isTemp = entity.isTemp
	}
	
	func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		entity.id = id
		entity.title = title
		entity.createdAt = createdAt
		entity.updatedAt = updatedAt
		entity.deleteDate = deleteDate
		entity.isTemp = isTemp
	}
	
	convenience init(entity: Entity) {
		self.init()
		getPropertiesFrom(entity: entity)
	}

	@discardableResult
	func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreEntity.managedObjectContext = context
		if let storedEntity = CoreEntity.getEntitieWith(id: id) {
			CoreEntity.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreEntity.managedObjectContext = context
			let newEntity = CoreEntity.createEntityNOTsave()
			CoreEntity.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
	func didDeleteEntity() {
		
	}
	
	static func ==(lhs: VEntity, rhs: VEntity?) -> Bool {
		if lhs.id == rhs?.id {
			return true
		}
		return false
	}

}

internal extension VEntity {
	
	func decodeDate<T:CodingKey>(container: KeyedDecodingContainer<T>, forKey: T) throws -> NSDate? {
		let dateString = try container.decodeIfPresent(String.self, forKey: forKey)
		if let date = dateString, let localizedDate = GlobalDateFormatter.UTCToLocal(date: date) {
			return localizedDate as NSDate
		} else {
			return nil
		}
	}
	
}

