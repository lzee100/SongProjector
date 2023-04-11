//
//  VSongServiceSettings.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import Firebase

public struct VSongServiceSettings: VEntityType, Codable {
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
    
	var sections: [VSongServiceSection] = []
	
	enum CodingKeysSongServiceSettings: String, CodingKey
	{
        case id
        case userUID
        case title
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
		case sections
    }
    
    init?() {
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
        sections = []
    }
    
    init?(songServiceSettings: SongServiceSettings, moc: NSManagedObjectContext) {
        self.id = songServiceSettings.id
        self.userUID = songServiceSettings.userUID
        self.title = songServiceSettings.title
        self.createdAt = songServiceSettings.createdAt
        self.updatedAt = songServiceSettings.updatedAt
        self.deleteDate = songServiceSettings.deleteDate
        self.rootDeleteDate = songServiceSettings.rootDeleteDate?.date
        self.sections = songServiceSettings.hasSections(moc: moc).map { VSongServiceSection(songServiceSection: $0, moc: moc) }
    }
    
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSongServiceSettings.self)
        
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
                
		try container.encode(sections, forKey: .sections)
	}
	
	
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
				
		let container = try decoder.container(keyedBy: CodingKeysSongServiceSettings.self)
        
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
        
		sections = try (container.decodeIfPresent([VSongServiceSection].self, forKey: .sections) ?? []).sorted(by: { $0.position < $1.position })		
	}
    
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let entity = entity as? SongServiceSettings {
                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                sections.forEach({ _ = $0.getManagedObject(context: context) })
                entity.sectionIds = sections.map({ $0.id }).joined(separator: ",")
            }
        }
        
        if let entity: SongServiceSettings = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SongServiceSettings = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

	
}
