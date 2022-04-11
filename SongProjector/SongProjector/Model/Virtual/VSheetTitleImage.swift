//
//  VSheetTitleImage.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FirebaseAuth

struct VSheetTitleImage: VSheet, SheetMetaType, Codable {
	
	static var type: SheetType = .SheetTitleImage
    
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
    var sheetType: SheetType {
        return .SheetTitleImage
    }

	var content: String? = nil
	var hasTitle: Bool = true
	var imageBorderColor: String? = nil
	var imageBorderSize: Int16 = 0
	var imageContentMode: Int16 = 0
	var imageHasBorder: Bool = false
    var imagePath: String? = nil
	var thumbnailPath: String? = nil
	var imagePathAWS: String? = nil
    
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
	
	
	enum CodingKeysTitleImage:String,CodingKey
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
		case hasTitle
		case imageBorderColor
		case imageBorderSize
		case imageContentMode
		case imageHasBorder
		case thumbnailPathAWS
		case imagePathAWS
	}
	
    init(id: String = "CHURCHBEAM" + UUID().uuidString, userUID: String, title: String?, createdAt: NSDate = Date().localDate() as NSDate, updatedAt: NSDate?, deleteDate: NSDate? = nil, rootDeleteDate: Date? = nil, isEmptySheet: Bool = false, position: Int = 0, time: Double = 0, hasTheme: VTheme? = nil, content: String? = nil, hasTitle: Bool = true, imageBorderColor: String? = nil, imageBorderSize: Int16 = 0, imageContentMode: Int16 = 0, imageHasBorder: Bool = false, imagePath: String? = nil, thumbnailPath: String? = nil, imagePathAWS: String? = nil) {
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
        self.hasTitle = hasTitle
        self.imageBorderColor = imageBorderColor
        self.imageBorderSize = imageBorderSize
        self.imageContentMode = imageContentMode
        self.imageHasBorder = imageHasBorder
        self.imagePath = imagePath
        self.thumbnailPath = thumbnailPath
        self.imagePathAWS = imagePathAWS
        
    }

	
	
	// MARK: - Encodable
	
    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTitleImage.self)
        
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

        
		try container.encode(Int(truncating: NSNumber(value: hasTitle)), forKey: .hasTitle)
		try container.encode(content, forKey: .content)
		try container.encode(imageBorderColor, forKey: .imageBorderColor)
		try container.encode(imageBorderSize, forKey: .imageBorderSize)
		try container.encode(imageContentMode, forKey: .imageContentMode)
		try container.encode(Int(truncating: NSNumber(value: imageHasBorder)), forKey: .imageHasBorder)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		
	}
	
	
	
	// MARK: - Decodable
	
	 public init(from decoder: Decoder) throws {
        
		let container = try decoder.container(keyedBy: CodingKeysTitleImage.self)
        
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

        
		hasTitle = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .hasTitle) ?? 0) as NSNumber)
		imageBorderColor = try container.decodeIfPresent(String.self, forKey: .imageBorderColor)
		content = try container.decodeIfPresent(String.self, forKey: .content)
		imageBorderSize = try container.decodeIfPresent(Int16.self, forKey: .imageBorderSize) ?? 0
		imageContentMode = try container.decodeIfPresent(Int16.self, forKey: .imageContentMode) ?? 0
		imageHasBorder = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .imageHasBorder) ?? 0) as NSNumber)
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
				
	}
	
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        
        func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
            if let sheet = entity as? SheetTitleImageEntity {
                
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
                
                sheet.content = content
                sheet.hasTitle = hasTitle
                sheet.imageBorderColor = imageBorderColor
                sheet.imageBorderSize = imageBorderSize
                sheet.imageContentMode = imageContentMode
                sheet.imageHasBorder = imageHasBorder
                sheet.imagePathAWS = imagePathAWS
                sheet.imagePath = imagePath
                sheet.thumbnailPath = thumbnailPath
            }
        }
        
        if let entity: SheetTitleImageEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SheetTitleImageEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

}
