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
import FirebaseAuth

protocol VEntityType {
    var id: String { get }
    var userUID: String { get }
    var title: String? { get }
    var createdAt: NSDate { get }
    var updatedAt: NSDate? { get }
    var deleteDate: NSDate? { get }
    var rootDeleteDate: Date? { get }

    func getManagedObject(context: NSManagedObjectContext) -> Entity
}

public struct VEntity: VEntityType, Codable {
	
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?

	
	enum CodingKeys: String, CodingKey
	{
		case id
		case title
        case userUID
		case createdAt
		case updatedAt
		case deleteDate = "deletedAt"
        case rootDeleteDate
	}
	
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString, userUID: String, title: String?, createdAt: NSDate = Date().localDate() as NSDate, updatedAt: NSDate?, deleteDate: NSDate? = nil, rootDeleteDate: Date? = nil) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.rootDeleteDate = rootDeleteDate
    }
    
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
        
		let container = try decoder.container(keyedBy: CodingKeys.self)

		id = try container.decode(String.self, forKey: .id)
		title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
//		isTemp = false
        let createdAtInt = try container.decode(Int64.self, forKey: .createdAt)
        let updatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .updatedAt)
        let deletedAtInt = try container.decodeIfPresent(Int64.self, forKey: .deleteDate)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt) / 1000) as NSDate

        if let updatedAtInt = updatedAtInt {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt) / 1000) as NSDate
        } else {
            updatedAt = nil
        }
        if let deletedAtInt = deletedAtInt {
            deleteDate = Date(timeIntervalSince1970: TimeInterval(deletedAtInt) / 1000) as NSDate
        } else {
            deleteDate = nil
        }
        if let rootdeleteDateInt = try container.decodeIfPresent(Int.self, forKey: .rootDeleteDate) {
            rootDeleteDate = Date(timeIntervalSince1970: TimeInterval(rootdeleteDateInt / 1000))
        } else {
            rootDeleteDate = nil
        }
	}
	
	
	
	// MARK: - Encodable
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(title, forKey: .title)
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        try container.encode(userUID, forKey: .userUID)

       try container.encode((createdAt as Date).intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
//            let updatedAtString = GlobalDateFormatter.localToUTCNumber(date: updatedAt as Date)
            try container.encode((updatedAt as Date).intValue, forKey: .updatedAt)
        } else {
            try container.encode((createdAt as Date).intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
//            let deleteDateString = GlobalDateFormatter.localToUTCNumber(date: deleteDate as Date)
            try container.encode((deleteDate as Date).intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
	}
	
//    convenience init(entity: Entity, context: NSManagedObjectContext) {
//		self.init()
//		getPropertiesFrom(entity: entity, context: context)
//	}

	@discardableResult
	func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            entity.id = id
            entity.title = title
            entity.userUID = userUID
            entity.createdAt = createdAt
            entity.updatedAt = updatedAt
            entity.deleteDate = deleteDate
    //        entity.isTemp = isTemp
            entity.rootDeleteDate = rootDeleteDate as NSDate?
        }
		
        if let entity: Entity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Entity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
	}
    
	static func ==(lhs: VEntity, rhs: VEntity?) -> Bool {
		if lhs.id == rhs?.id {
			return true
		}
		return false
	}

}

internal extension VEntity {
	
//	func decodeDate<T:CodingKey>(container: KeyedDecodingContainer<T>, forKey: T) throws -> NSDate? {
//		let dateString = try container.decodeIfPresent(Int.self, forKey: forKey)
//		if let date = dateString, let localizedDate = GlobalDateFormatter.UTCToLocalNumber(date: date) {
//			return localizedDate as NSDate
//		} else {
//			return nil
//		}
//	}
	
}

