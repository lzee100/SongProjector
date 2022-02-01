//
//  VSheet.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth

protocol VSheet {
    var isNew: Bool { get }
    var isEmptySheet: Bool { get set }
    var position: Int { get set }
    var time: Double { get set }
    var hasTheme: VTheme? { get set }
    var sheetType: SheetType { get }
}


struct VSheetEntity {
	
    let id: String
    let userUID: String
    let title: String?
    let createdAt: NSDate
    let updatedAt: NSDate?
    let deleteDate: NSDate?
    let rootDeleteDate: Date?
    
    var isNew: Bool {
        return updatedAt == nil
    }
	var isEmptySheet = false
	var position: Int = 0
	var time: Double = 0
	var hasTheme: VTheme? = nil
	
	enum CodingKeysSheet:String,CodingKey
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
	}
	
	var type: SheetType {
		if self is VSheetTitleContent {
			return .SheetTitleContent
		} else if self is VSheetTitleImage {
			return .SheetTitleImage
		} else if self is VSheetSplit {
			return .SheetSplit
		} else if self is VSheetPastors {
			return .SheetPastors
		} else if self is VSheetActivities {
			return .SheetActivities
		} else {
			return .SheetEmpty
		}
	}
    
    


	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString, userUID: String, title: String?, createdAt: NSDate = Date().localDate() as NSDate, updatedAt: NSDate?, deleteDate: NSDate? = nil, rootDeleteDate: Date? = nil, isEmptySheet: Bool = false, position: Int = 0, time: Double = 0, hasTheme: VTheme? = nil) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.rootDeleteDate = rootDeleteDate
        
        self.isEmptySheet = isEmptySheet
        self.position = position
        self.time = time
        self.hasTheme = hasTheme
    }
    
	
	
	// MARK: - Encodable
	
    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysSheet.self)
        
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
	}
	
	
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
				
		let container = try decoder.container(keyedBy: CodingKeysSheet.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
//        isTemp = false
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
		
	}
	
	public func isEqualTo(_ object: Any?) -> Bool {
		if let sheet = object as? Sheet {
			return self.id == sheet.id
		}
		return false
	}
	
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Sheet, context: NSManagedObjectContext) {
            entity.id = id
            entity.title = title
            entity.userUID = userUID
            entity.createdAt = createdAt
            entity.updatedAt = updatedAt
            entity.deleteDate = deleteDate
    //        entity.isTemp = isTemp
            entity.rootDeleteDate = rootDeleteDate as NSDate?

            
            entity.isEmptySheet = isEmptySheet
            entity.position = Int16(position)
            entity.time = time
            entity.hasTheme = hasTheme?.getManagedObject(context: context)
        }
        
        if let entity: Sheet = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Sheet = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }
	
	
}
