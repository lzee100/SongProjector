//
//  SheetTitleImageCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct SheetTitleImageCodable: EntityCodableType, SheetMetaType {
    
    init?(managedObject: NSManagedObject, context: NSManagedObjectContext) {
        guard let entity = managedObject as? SheetTitleImageEntity else { return nil }
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
        
        isEmptySheet = entity.isEmptySheet
        position = Int(entity.position)
        time = entity.time
        if let theme = entity.hasTheme {
            hasTheme = ThemeCodable(managedObject: theme, context: context)
        }
        content = entity.content
        hasTitle = entity.hasTitle
        imageBorderColor = entity.imageBorderColor
        imageBorderSize = entity.imageBorderSize
        imageContentMode = entity.imageContentMode
        imageHasBorder = entity.imageHasBorder
        imagePath = entity.imagePath
        thumbnailPath = entity.thumbnailPath
        imagePathAWS = entity.imagePathAWS
    }
    
    func getManagedObjectFrom(_ context: NSManagedObjectContext) -> NSManagedObject {
        
        if let entity: SheetTitleImageEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity, context: context)
            return entity
        } else {
            let entity: SheetTitleImageEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity, context: context)
            return entity
        }
    }
    
    private func setPropertiesTo(_ entity: SheetTitleImageEntity, context: NSManagedObjectContext) {
        entity.id = id
        entity.userUID = userUID
        entity.title = title
        entity.createdAt = createdAt.nsDate
        entity.updatedAt = updatedAt?.nsDate
        entity.deleteDate = deleteDate?.nsDate
        entity.rootDeleteDate = rootDeleteDate?.nsDate
        
        entity.isEmptySheet = isEmptySheet
        entity.position = Int16(position)
        entity.time = time
        entity.hasTheme = hasTheme?.getManagedObjectFrom(context) as? Theme
        
        entity.content = content
        entity.hasTitle = hasTitle
        entity.imageBorderColor = imageBorderColor
        entity.imageBorderSize = imageBorderSize
        entity.imageContentMode = imageContentMode
        entity.imageHasBorder = imageHasBorder
        entity.imagePath = imagePath
        entity.thumbnailPath = thumbnailPath
        entity.imagePathAWS = imagePathAWS
    }
    
    static var type: SheetType = .SheetTitleImage
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date().localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    var isEmptySheet: Bool = false
    var position: Int = 0
    var time: Double = 0
    var hasTheme: ThemeCodable? = nil
    var content: String? = nil
    var hasTitle: Bool = true
    var imageBorderColor: String? = nil
    var imageBorderSize: Int16 = 0
    var imageContentMode: Int16 = 0
    var imageHasBorder: Bool = false
    var imagePath: String? = nil
    var thumbnailPath: String? = nil
    var imagePathAWS: String? = nil
    
    enum CodingKeysSheetTitleImage:String,CodingKey
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
    
    init(
        id: String,
        userUID: String,
        title: String?,
        createdAt: Date,
        updatedAt: Date?,
        deleteDate: Date?,
        isTemp: Bool,
        rootDeleteDate: Date?,
        isEmptySheet: Bool,
        position: Int,
        time: Double,
        hasTheme: ThemeCodable?,
        content: String?,
        hasTitle: Bool,
        imageBorderColor: String?,
        imageBorderSize: Int16,
        imageContentMode: Int16,
        imageHasBorder: Bool,
        imagePath: String?,
        thumbnailPath: String?,
        imagePathAWS: String?
    ) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.isTemp = isTemp
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysSheetTitleImage.self)
        
        hasTitle = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .hasTitle) ?? 0) as NSNumber)
        imageBorderColor = try container.decodeIfPresent(String.self, forKey: .imageBorderColor)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        imageBorderSize = try container.decodeIfPresent(Int16.self, forKey: .imageBorderSize) ?? 0
        imageContentMode = try container.decodeIfPresent(Int16.self, forKey: .imageContentMode) ?? 0
        imageHasBorder = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .imageHasBorder) ?? 0) as NSNumber)
        imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
        
        isEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isEmptySheet) ?? 0) as NSNumber)
        position = Int(try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0)
        let sheetTimeString = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
        time = Double(sheetTimeString) ?? 0.0
        hasTheme = try container.decodeIfPresent(ThemeCodable.self, forKey: .hasTheme)
        
        id  = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
        
        id  = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
        
        let createdAtInt = try container.decode(Int64.self, forKey: .createdAt)
        let updatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .updatedAt)
        let deletedAtInt = try container.decodeIfPresent(Int64.self, forKey: .deleteDate)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt) / 1000)
        
        if let updatedAtInt = updatedAtInt {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt) / 1000)
        }
        if let deletedAtInt = deletedAtInt {
            deleteDate = Date(timeIntervalSince1970: TimeInterval(deletedAtInt) / 1000)
        }
        if let rootdeleteDateInt = try container.decodeIfPresent(Int.self, forKey: .rootDeleteDate) {
            rootDeleteDate = Date(timeIntervalSince1970: TimeInterval(rootdeleteDateInt))
        }
    }
    
    
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSheetTitleImage.self)
        
        try container.encode(Int(truncating: NSNumber(value: hasTitle)), forKey: .hasTitle)
        try container.encode(content, forKey: .content)
        try container.encode(imageBorderColor, forKey: .imageBorderColor)
        try container.encode(imageBorderSize, forKey: .imageBorderSize)
        try container.encode(imageContentMode, forKey: .imageContentMode)
        try container.encode(Int(truncating: NSNumber(value: imageHasBorder)), forKey: .imageHasBorder)
        try container.encode(imagePathAWS, forKey: .imagePathAWS)
        
        try container.encode(Int(truncating: NSNumber(value: isEmptySheet)), forKey: .isEmptySheet)
        try container.encode(position, forKey: .position)
        try container.encode(id, forKey: .id)
        try container.encode(time.stringValue, forKey: .time)
        if hasTheme != nil {
            try container.encode(hasTheme, forKey: .hasTheme)
        }
        
        try container.encodeIfPresent(title, forKey: .title)
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        try container.encode(userUID, forKey: .userUID)

       try container.encode((createdAt as Date).intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
            try container.encode((updatedAt as Date).intValue, forKey: .updatedAt)
        } else {
            try container.encode((createdAt as Date).intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
            try container.encode((deleteDate as Date).intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
    }
}
