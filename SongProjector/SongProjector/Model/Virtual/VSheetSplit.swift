//
//  VSheetSplit.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth

struct VSheetSplit: VSheet, SheetMetaType, Codable {
	
	static let type: SheetType = .SheetSplit
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
    
    var isNew: Bool {
        return updatedAt == nil
    }
    var isEmptySheet = false
    var position: Int = 0
    var time: Double = 0
    var hasTheme: VTheme? = nil
    var sheetType: SheetType {
        return .SheetEmpty
    }
	
	var textLeft: String?
	var textRight: String?

	
	enum CodingKeysSheetSplit:String,CodingKey
	{
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case isEmptySheet
        case position
        case time
        case hasCluster = "cluster"
        case hasTheme = "theme"
        
		case textLeft = "contentLeft"
		case textRight = "contentRight"
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
    }
	
	// MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSheetSplit.self)
        
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
        
        try container.encode(Int(truncating: NSNumber(value: isEmptySheet)), forKey: .isEmptySheet)
        try container.encode(position, forKey: .position)
        try container.encode(id, forKey: .id)
        try container.encode(time.stringValue, forKey: .time)
        if hasTheme != nil {
            try container.encode(hasTheme, forKey: .hasTheme)
        }
        
		try container.encode(textLeft, forKey: .textLeft)
		try container.encode(textRight, forKey: .textRight)
	}
	
	
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
				
		let container = try decoder.container(keyedBy: CodingKeysSheetSplit.self)
        
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
        
        isEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isEmptySheet) ?? 0) as NSNumber)
        position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
        let sheetTimeString = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
        time = Double(sheetTimeString) ?? 0.0
        hasTheme = try container.decodeIfPresent(VTheme.self, forKey: .hasTheme)
        
		textLeft = try container.decodeIfPresent(String.self, forKey: .textLeft)
		textRight = try container.decodeIfPresent(String.self, forKey: .textRight)
		
	}
	
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let sheet = entity as? SheetSplitEntity {
                
                sheet.id = id
                sheet.title = title
                sheet.userUID = userUID
                sheet.createdAt = createdAt
                sheet.updatedAt = updatedAt
                sheet.deleteDate = deleteDate
        //        entity.isTemp = isTemp
                sheet.rootDeleteDate = rootDeleteDate as NSDate?
                
                sheet.isEmptySheet = isEmptySheet
                sheet.position = Int16(position)
                sheet.time = time
                sheet.hasTheme = hasTheme?.getManagedObject(context: context) as? Theme
                
                sheet.textLeft = self.textLeft
                sheet.textRight = self.textRight
                
            }
        }
        
        if let entity: SheetSplitEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SheetSplitEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }
}
