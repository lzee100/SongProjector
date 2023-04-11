//
//  VSheetPastors.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FirebaseAuth


struct VSheetPastors: VSheet, SheetMetaType, Codable {
    
    static var type: SheetType = .SheetPastors
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
	
	var content: String? = nil
	var imagePath: String? = nil
	var thumbnailPath: String? = nil
	var imagePathAWS: String? = nil
	var thumbnailPathAWS: String? = nil
    
    var isNew: Bool {
        return updatedAt == nil
    }
    var isEmptySheet = false
    var position: Int = 0
    var time: Double = 0
    var hasTheme: VTheme? = nil
    var sheetType: SheetType {
        return .SheetPastors
    }
    
    var tempSelectedImage: UIImage? {
        didSet {
            tempSelectedImageThumbNail = tempSelectedImage?.resized(withPercentage: 0.5)
        }
    }
    var tempSelectedImageThumbNail: UIImage?
    var isTempSelectedImageDeleted = false
    var tempLocalImageName: String?
    
    var hasNewRemoteImage: Bool {
        if let imagePathAWS = imagePathAWS {
            if
                let imagePath = imagePath,
                let url = URL(string: imagePath),
                let remoteURL = URL(string: imagePathAWS),
                url.lastPathComponent == remoteURL.lastPathComponent
            {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    

	// not saving image path local
	enum CodingKeysPastors:String,CodingKey
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
        
		case content
		case imagePath
		case thumbnailPath
		case imagePathAWS
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
    
    init(_ entity: SheetPastorsEntity) {
        self.id = entity.id
        self.userUID = entity.userUID
        self.title = entity.title
        self.createdAt = entity.createdAt
        self.updatedAt = entity.updatedAt
        self.deleteDate = entity.deleteDate
        self.rootDeleteDate = entity.rootDeleteDate?.date
        self.content = entity.content
        self.imagePath = entity.imagePath
        self.thumbnailPath = entity.thumbnailPath
        self.imagePathAWS = entity.imagePathAWS
        self.thumbnailPathAWS = entity.thumbnailPathAWS
        self.isEmptySheet = entity.isEmptySheet
        self.position = entity.position.intValue
        self.time = entity.time
        self.hasTheme = VTheme(theme: entity.hasTheme)
    }
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString, userUID: String, title: String?, createdAt: NSDate = Date().localDate() as NSDate, updatedAt: NSDate?, deleteDate: NSDate? = nil, rootDeleteDate: Date? = nil, isEmptySheet: Bool = false, position: Int = 0, time: Double = 0, hasTheme: VTheme? = nil, content: String? = nil, imagePath: String? = nil, thumbnailPath: String? = nil, imagePathAWS: String? = nil, thumbnailPathAWS: String? = nil) {

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

        self.content = content
        self.imagePath = imagePath
        self.thumbnailPath = thumbnailPath
        self.imagePathAWS = imagePathAWS
        self.thumbnailPathAWS = thumbnailPathAWS
        
    }
	
	
	// MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysPastors.self)
        
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
        
		try container.encode(content, forKey: .content)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
	}
	

	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeysPastors.self)
        
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


		content = try container.decodeIfPresent(String.self, forKey: .content)
		// FixMe: delete image paths local
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		
	}
	
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let sheet = entity as? SheetPastorsEntity {
                
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
                
                sheet.content = self.content
                sheet.imagePath = self.imagePath
                sheet.thumbnailPath = self.thumbnailPath
                if imagePathAWS == nil {
                    sheet.imagePath = nil
                    sheet.thumbnailPath = nil
                }
                sheet.imagePathAWS = self.imagePathAWS
            }
        }
        
        if let entity: SheetPastorsEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SheetPastorsEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

	

}
