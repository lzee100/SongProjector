//
//  VSongServiceSection.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import Firebase

struct VSongServiceSection: VEntityType, Codable {
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
		
	var position: Int16 = 0
	var numberOfSongs: Int16 = 0
	var tagIds: [String] = []
	var hasSongServiceSettings: VSongServiceSettings? = nil

    func hasTags(moc: NSManagedObjectContext) -> [VTag] {
        let persitentTags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted])
        return persitentTags.filter({ tag in tagIds.contains(tag.id) }).compactMap({ VTag(tag: $0) })
    }
    	
	enum CodingKeysSongServiceSection: String, CodingKey
	{
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
		case position
		case numberOfSongs
		case tags
	}
    
    public init?() {
        id = "CHURCHBEAM" + UUID().uuidString
        title = nil
        guard let userUID = Auth.auth().currentUser?.uid else {
            return nil
        }
        self.userUID = userUID
        createdAt = Date().localDate().nsDate
        updatedAt = nil
        deleteDate = nil
        rootDeleteDate = nil
        position = 0
        numberOfSongs = 0
        tagIds = []
        hasSongServiceSettings = nil
    }

    public init(songServiceSection: SongServiceSection, moc: NSManagedObjectContext) {
        self.id = songServiceSection.id
        self.title = songServiceSection.title
        self.userUID = songServiceSection.userUID
        self.createdAt = songServiceSection.createdAt
        self.updatedAt = songServiceSection.updatedAt
        self.deleteDate = songServiceSection.deleteDate
        self.rootDeleteDate = songServiceSection.rootDeleteDate as? Date
        self.position = songServiceSection.position
        self.numberOfSongs = songServiceSection.numberOfSongs
        self.tagIds = songServiceSection.hasTags(moc: moc).map { $0.id }
    }
		
	// MARK: - Encodable
	
    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSongServiceSection.self)
        
        try container.encode(id, forKey: .id)
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
        
		try container.encode(position, forKey: .position)
		try container.encode(numberOfSongs, forKey: .numberOfSongs)
		try container.encode(hasTags(moc: newMOCBackground), forKey: .tags)
	}
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: CodingKeysSongServiceSection.self)
        
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
        
        position = try container.decode(Int16.self, forKey: .position)
        numberOfSongs = try container.decode(Int16.self, forKey: .numberOfSongs)
        let tags = try (container.decodeIfPresent([VTag].self, forKey: .tags) ?? []).sorted(by: { $0.position < $1.position })
        tagIds = tags.map { $0.id }
    }

    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let entity = entity as? SongServiceSection {
                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                entity.position = position
                entity.numberOfSongs = numberOfSongs
                entity.tagIds = tagIds.joined(separator: ",")
                entity.id = id
            }
        }
        
        if let entity: SongServiceSection = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SongServiceSection = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

	
}
