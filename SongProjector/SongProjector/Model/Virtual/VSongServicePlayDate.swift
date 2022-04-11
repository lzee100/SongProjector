//
//  VSongServicePlayDate.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VSongServicePlayDate: VEntity {
    
    let id: String
    let userUID: String
    let title: String?
    let createdAt: NSDate
    let updatedAt: NSDate?
    let deleteDate: NSDate?
    let rootDeleteDate: Date?
    
    var playDate: Date? = nil
    var appInstallId: String?
    
    var allowedToPlay: Bool {
        if let appInstallId = UserDefaults.standard.object(forKey: ApplicationIdentifier) as? String {
            if appInstallId == self.appInstallId {
                return true
            } else {
                // if someone else played, it should be 110 before this one
                let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
                let vUser = [user].compactMap({ $0 }).map({ VUser(user: $0, context: moc) }).first
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
    
    
    
    // MARK: - Encodable
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appInstallId, forKey: .appInstallid)
        if let playDate = playDate {
            try container.encode((playDate as Date).intValue, forKey: .playDate)
        }
        try super.encode(to: encoder)
    }
    
    
    
    // MARK: - Decodable
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let playDateInt = try container.decodeIfPresent(Int.self, forKey: .playDate) {
            playDate = Date(timeIntervalSince1970: TimeInterval(playDateInt / 1000))
        }
        appInstallId = try container.decodeIfPresent(String.self, forKey: .appInstallid)
        try super.initialization(decoder: decoder)
    }
    
   override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
        super.setPropertiesTo(entity: entity, context: context)
        if let songServicePlayDate = entity as? SongServicePlayDate {
            songServicePlayDate.playDate = self.playDate
            songServicePlayDate.appInstallId = self.appInstallId
        }
    }
    
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
        if let songServicePlayDate = entity as? SongServicePlayDate {
            appInstallId = songServicePlayDate.appInstallId
            playDate = songServicePlayDate.playDate
        }
    }
    
    convenience init(entity: Entity, context: NSManagedObjectContext) {
        self.init()
        getPropertiesFrom(entity: entity, context: context)
    }
    
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
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
