//
//  VUser.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

struct VUser: VEntityType, Codable {
    
    let id: String
    let userUID: String
    let title: String?
    let createdAt: NSDate
    let updatedAt: NSDate?
    let deleteDate: NSDate?
    let rootDeleteDate: Date?
    
    private let productExpireDateKey = "churchbeamProductExpireDateKey"
    private let productIdKey = "churchbeamProductIdKey"
    private let productPilotDateKey = "productPilotDateKey"

    class func first(moc: NSManagedObjectContext, predicates: [NSPredicate] = []) -> VUser? {
        let user: User? = DataFetcher().getEntity(moc: moc, predicates: predicates)
        if let user = user {
            return VUser(entity: user, context: moc)
        }
        return nil
    }
    
    class func getUsers(moc: NSManagedObjectContext, predicates: [NSPredicate] = [], sort: NSSortDescriptor? = nil) -> [VUser] {
        let users: [User] = DataFetcher().getEntities(moc: moc, predicates: predicates, sort: sort)
        return users.map({ VUser(entity: $0, context: moc) })
    }
    
	var appInstallTokens: [String] = []        
    var sheetTimeOffset: Double = 0
    var adminCode: String? = nil
    var adminInstallTokenId: String? = nil
    var googleCalendarId: String? = nil
    var productExpireDate: Date? {
        set {
            if let date = newValue {
                KeychainService.updateItem(date.intValue.stringValue, serviceKey: productExpireDateKey)
            } else {
                KeychainService.removeItem(serviceKey: productExpireDateKey)
            }
        }
        get {
            if let item = KeychainService.loadItem(serviceKey: productExpireDateKey), let time = Int64(item) {
                return Date(timeIntervalSince1970: TimeInterval(time) / 1000)
            }
            return nil
        }
    }
    var pilotStartDate: Date? {
        set {
            if let date = newValue {
                KeychainService.updateItem(date.intValue.stringValue, serviceKey: productPilotDateKey)
            } else {
                KeychainService.removeItem(serviceKey: productPilotDateKey)
            }
        }
        get {
            if let item = KeychainService.loadItem(serviceKey: productPilotDateKey), let time = Int64(item) {
                return Date(timeIntervalSince1970: TimeInterval(time) / 1000)
            }
            return nil
        }
    }
    var productId: String? {
        set {
            if let id = newValue {
                KeychainService.updateItem(id, serviceKey: productIdKey)
            } else {
                KeychainService.removeItem(serviceKey: productIdKey)
            }
        }
        get {
            return KeychainService.loadItem(serviceKey: productIdKey)
        }
    }
    var hasActiveBeamContract: Bool {
        guard let expDate = productExpireDate, let productId = productId, let product = IAPProduct(productId), expDate.isAfter(Date()) else {
            return false
        }
        switch product {
        case .beam: return true
        case .song: return false
        }
    }
    var hasActiveSongContract: Bool {
        guard let expDate = productExpireDate, let productId = productId, let product = IAPProduct(productId), expDate.isAfter(Date()) else {
            return false
        }
        switch product {
        case .beam: return false
        case .song: return true
        }
    }
    
    var isAdmin: Bool {
        return adminInstallTokenId == (UserDefaults.standard.object(forKey: ApplicationIdentifier) as? String)
    }
	
	enum CodingKeysUser: String, CodingKey
	{
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
		case appInstallTokens
		case roleId
        case contractType
        case pilotStartDate
        case sheetTimeOffset
        case adminCode
        case adminInstallTokenId
        case googleCalendarId
        case productExpireDate
        case productId
	}
		
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysUser.self)
        
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
        
        
		let installTokens = try container.decodeIfPresent(String.self, forKey: .appInstallTokens) ?? ""
        appInstallTokens = installTokens.split(separator: ",").compactMap({ String($0) })
        if let sheetTimeOffsetString = try container.decodeIfPresent(Int.self, forKey: .sheetTimeOffset) {
            sheetTimeOffset = Double(sheetTimeOffsetString)
        }
        if let pilotStartDateInt = try container.decodeIfPresent(Int64.self, forKey: .pilotStartDate) {
            pilotStartDate = Date(timeIntervalSince1970: TimeInterval(pilotStartDateInt) / 1000)
        }
        if let productExpireDateInt = try container.decodeIfPresent(Int64.self, forKey: .productExpireDate) {
            productExpireDate = Date(timeIntervalSince1970: TimeInterval(productExpireDateInt) / 1000)
        }

        adminCode = try container.decodeIfPresent(String.self, forKey: .adminCode)
        adminInstallTokenId = try container.decodeIfPresent(String.self, forKey: .adminInstallTokenId)
        googleCalendarId = try container.decodeIfPresent(String.self, forKey: .googleCalendarId)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)

		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysUser.self)
        
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
        
        try container.encode(eventDescription, forKey: .eventDescription)
        
        if let startDate = startDate {
            try container.encode((startDate as Date).intValue, forKey: .startDate)
        }
        if let endDate = endDate {
            try container.encode((endDate as Date).intValue, forKey: .endDate)
        }
        
        try container.encode(appInstallTokens.joined(separator: ","), forKey: .appInstallTokens)
        try container.encode("\(sheetTimeOffset)", forKey: .sheetTimeOffset)
        if let pilotStartDate = pilotStartDate {
            try container.encode(pilotStartDate.intValue, forKey: .pilotStartDate)
        }
        try container.encode(adminCode, forKey: .adminCode)
        try container.encode(adminInstallTokenId, forKey: .adminInstallTokenId)
        try container.encode(googleCalendarId, forKey: .googleCalendarId)
        try container.encode(productId, forKey: .productId)
        try container.encode(productExpireDate?.intValue ?? 0, forKey: .productExpireDate)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
        let container = try decoder.container(keyedBy: CodingKeysUser.self)
        
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
        
		
        if let installTokens = try container.decodeIfPresent(String.self, forKey: .appInstallTokens) {
            appInstallTokens = installTokens.split(separator: ",").compactMap({ String($0) })
        } else {
            appInstallTokens = []
        }
        if let offset = try container.decodeIfPresent(String.self, forKey: .sheetTimeOffset) {
            sheetTimeOffset = Double(offset) ?? 0
        }
        if let pilotStartDateInt = try container.decodeIfPresent(Int.self, forKey: .pilotStartDate) {
            pilotStartDate = Date(timeIntervalSince1970: TimeInterval(pilotStartDateInt) / 1000)
        }
        if let productExpireDateInt = try container.decodeIfPresent(Int64.self, forKey: .productExpireDate), productExpireDateInt > 0 {
            productExpireDate = Date(timeIntervalSince1970: TimeInterval(productExpireDateInt) / 1000)
        }
        adminCode = try container.decodeIfPresent(String.self, forKey: .adminCode)
        adminInstallTokenId = try container.decodeIfPresent(String.self, forKey: .adminInstallTokenId)
        googleCalendarId = try container.decodeIfPresent(String.self, forKey: .googleCalendarId)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        
		try super.initialization(decoder: decoder)
		
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let user = entity as? User {
            user.appInstallTokens = self.appInstallTokens.joined(separator: ",")
            user.sheetTimeOffset = "\(sheetTimeOffset)"
            user.adminCode = adminCode
            user.adminInstallTokenId = adminInstallTokenId
            user.googleCalendarId = googleCalendarId
		}
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let user = entity as? User {
            appInstallTokens = user.appInstallTokens?.split(separator: ",").compactMap({ String($0) }) ?? []
            sheetTimeOffset = Double(user.sheetTimeOffset) ?? 0
            adminCode = user.adminCode
            adminInstallTokenId = user.adminInstallTokenId
            googleCalendarId = user.googleCalendarId
		}
	}
	
	convenience init(user: User, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: user, context: context)
	}
	
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let entity = entity as? User {
                entity.id = id
                entity.title = title
                entity.userUID = userUID
                entity.createdAt = createdAt
                entity.updatedAt = updatedAt
                entity.deleteDate = deleteDate
                entity.rootDeleteDate = rootDeleteDate as NSDate?
                
                entity.appInstallTokens = self.appInstallTokens.joined(separator: ",")
                entity.sheetTimeOffset = "\(sheetTimeOffset)"
                entity.adminCode = adminCode
                entity.adminInstallTokenId = adminInstallTokenId
                entity.googleCalendarId = googleCalendarId

            }
        }

        
        if let entity: User = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: User = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

	
}
