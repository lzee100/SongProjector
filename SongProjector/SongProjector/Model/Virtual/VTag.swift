//
//  VTag.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public struct VTag: VEntityType, Codable {
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
	    
	var position: Int16 = 0
    var isDeletable = true
	var hasSongServiceSections: [VSongServiceSection] = []
    
	enum CodingKeysTag: String, CodingKey {
        
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
		case position
        case isDeletable
	}
		
    public init(tag: Tag) {
        id = tag.id
        userUID = tag.userUID
        title = tag.title
        createdAt = tag.createdAt
        updatedAt = tag.updatedAt
        deleteDate = tag.deleteDate
        rootDeleteDate = tag.rootDeleteDate?.date
        
        position = tag.position
        isDeletable = tag.isDeletable
        hasSongServiceSections = (tag.hasSongServiceSections?.allObjects as? [SongServiceSection])?.map { VSongServiceSection(songServiceSection: $0, moc: moc) } ?? []
    }
	
	// MARK: - Encodable
	
    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTag.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userUID, forKey: .userUID)
        try container.encodeIfPresent(title, forKey: .title)
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
                
		try container.encode(position, forKey: .position)
        try container.encode(Int(truncating: NSNumber(value: isDeletable)), forKey: .isDeletable)
	}
	
	
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
				
		let container = try decoder.container(keyedBy: CodingKeysTag.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
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
        
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
        isDeletable = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isDeletable) ?? 0) as NSNumber)
		
	}
	
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let entity = entity as? Tag {
                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                entity.position = position
                entity.isDeletable = isDeletable
            }
        }
        
        if let entity: Tag = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Tag = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }
}
