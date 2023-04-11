//
//  VSongServicePlayDate.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth

public struct VSongServicePlayDate: VEntityType, Codable {
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
    
    var playDate: Date? = nil
    var appInstallId: String?
    
    var allowedToPlay: Bool {
        if let appInstallId = UserDefaults.standard.object(forKey: ApplicationIdentifier) as? String {
            if appInstallId == self.appInstallId {
                return true
            } else {
                // if someone else played, it should be 110 before this one
                let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
                let vUser = [user].compactMap({ $0 }).map({ VUser(user: $0) }).first
                return (vUser?.isAdmin ?? false) || (playDate?.isBefore(Date().dateByAddingMinutes(70)) ?? true && UserDefaults.standard.string(forKey: ApplicationIdentifier) != appInstallId)
            }
        } else {
            return true
        }
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case playDate
        case appInstallid
    }
    
    init?(songServicePlayDate: SongServicePlayDate? = nil) {
        
        if let songServicePlayDate = songServicePlayDate {
            self.id = songServicePlayDate.id
            self.userUID = songServicePlayDate.userUID
            self.title = songServicePlayDate.title
            self.createdAt = songServicePlayDate.createdAt
            self.updatedAt = songServicePlayDate.updatedAt
            self.deleteDate = songServicePlayDate.deleteDate
            self.rootDeleteDate = songServicePlayDate.rootDeleteDate?.date
            self.playDate = songServicePlayDate.playDate
            self.appInstallId = songServicePlayDate.appInstallId
        } else {
            guard let userUID = Auth.auth().currentUser?.uid else {
                return nil
            }
            self.id = "CHURCHBEAM" + UUID().uuidString
            self.userUID = userUID
            self.title = nil
            self.createdAt = Date().localDate().nsDate
            self.updatedAt = nil
            self.deleteDate = nil
            self.rootDeleteDate = nil
            self.playDate = nil
            self.appInstallId = nil
        }
    }
    
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
                
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

        try container.encode(appInstallId, forKey: .appInstallid)
        if let playDate = playDate {
            try container.encode((playDate as Date).intValue, forKey: .playDate)
        }
    }
    
    
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
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
        
        if let playDateInt = try container.decodeIfPresent(Int.self, forKey: .playDate) {
            playDate = Date(timeIntervalSince1970: TimeInterval(playDateInt / 1000))
        }
        appInstallId = try container.decodeIfPresent(String.self, forKey: .appInstallid)
    }
    
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            
            if let entity = entity as? SongServicePlayDate {

                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                entity.playDate = playDate
                entity.appInstallId = appInstallId
            }
        }

        
        if let entity: SongServicePlayDate = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SongServicePlayDate = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

}
