//
//  ThemeCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData
import UIKit

struct ThemeCodable: EntityCodableType {
    
    static func makeDefault(isDeletable: Bool = true, isHidden: Bool = false) -> ThemeCodable? {
        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: false))
        let position = (themes.first?.position ?? 0) + 1
        
        #if DEBUG
        let userId = "userid"
        #else
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        #endif
        
        return ThemeCodable(
            userUID: userId,
            title: AppText.NewTheme.sampleTitle,
            createdAt: Date(),
            updatedAt: Date(),
            deleteDate: nil,
            rootDeleteDate: nil,
            allHaveTitle: false,
            backgroundColor: UIColor(hex: "FFFFFF")!.hexCode,
            backgroundTransparancyNumber: 100,
            displayTime: false,
            hasEmptySheet: false,
            imagePath: nil,
            imagePathThumbnail: nil,
            isEmptySheetFirst: false,
            isHidden: false,
            isContentBold: false,
            isContentItalic: false,
            isContentUnderlined: false,
            isTitleBold: false,
            isTitleItalic: false,
            isTitleUnderlined: false,
            contentAlignmentNumber: 0,
            contentBorderColorHex: nil,
            contentBorderSize: 0,
            contentFontName: "Avenir",
            contentTextColorHex: UIColor(hex: "000000")?.hexCode,
            contentTextSize: 10,
            position: position,
            titleAlignmentNumber: 0,
            titleBackgroundColor: nil,
            titleBorderColorHex: nil,
            titleBorderSize: 0,
            titleFontName: "Avenir",
            titleTextColorHex: UIColor(hex: "000000")?.hexCode,
            titleTextSize: 14,
            imagePathAWS: nil,
            isUniversal: false,
            isDeletable: isDeletable,
            tempSelectedImage: nil,
            newSelectedThemeImageTempDirPath: nil,
            newSelectedSheetImageTempDirPath: nil,
            newSelectedThemeImageThumbTempDirPath: nil,
            newSelectedSheetImageThumbTempDirPath: nil,
            isThemeImageDeleted: false,
            isSheetImageDeleted: false
            )
    }
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString,
         userUID: String,
         title: String?,
         createdAt: Date,
         updatedAt: Date?,
         deleteDate: Date?,
         rootDeleteDate: Date?,
         allHaveTitle: Bool,
         backgroundColor: String?,
         backgroundTransparancyNumber: Double,
         displayTime: Bool,
         hasEmptySheet: Bool,
         imagePath: String?,
         imagePathThumbnail: String?,
         isEmptySheetFirst: Bool,
         isHidden: Bool,
         isContentBold: Bool,
         isContentItalic: Bool,
         isContentUnderlined: Bool,
         isTitleBold: Bool,
         isTitleItalic: Bool,
         isTitleUnderlined: Bool,
         contentAlignmentNumber: Int16,
         contentBorderColorHex: String?,
         contentBorderSize: Float,
         contentFontName: String?,
         contentTextColorHex: String?,
         contentTextSize: Float,
         position: Int16,
         titleAlignmentNumber: Int16,
         titleBackgroundColor: String?,
         titleBorderColorHex: String?,
         titleBorderSize: Float,
         titleFontName: String?,
         titleTextColorHex: String?,
         titleTextSize: Float,
         imagePathAWS: String?,
         isUniversal: Bool,
         isDeletable: Bool,
         tempSelectedImage: UIImage?,
         newSelectedThemeImageTempDirPath: String?,
         newSelectedSheetImageTempDirPath: String?,
         newSelectedThemeImageThumbTempDirPath: String?,
         newSelectedSheetImageThumbTempDirPath: String?,
         isThemeImageDeleted: Bool,
         isSheetImageDeleted: Bool) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.rootDeleteDate = rootDeleteDate
        self.allHaveTitle = allHaveTitle
        self.backgroundColor = backgroundColor
        self.backgroundTransparancyNumber = backgroundTransparancyNumber
        self.displayTime = displayTime
        self.hasEmptySheet = hasEmptySheet
        self.imagePath = imagePath
        self.imagePathThumbnail = imagePathThumbnail
        self.isEmptySheetFirst = isEmptySheetFirst
        self.isHidden = isHidden
        self.isContentBold = isContentBold
        self.isContentItalic = isContentItalic
        self.isContentUnderlined = isContentUnderlined
        self.isTitleBold = isTitleBold
        self.isTitleItalic = isTitleItalic
        self.isTitleUnderlined = isTitleUnderlined
        self.contentAlignmentNumber = contentAlignmentNumber
        self.contentBorderColorHex = contentBorderColorHex
        self.contentBorderSize = contentBorderSize
        self.contentFontName = contentFontName
        self.contentTextColorHex = contentTextColorHex
        self.contentTextSize = contentTextSize
        self.position = position
        self.titleAlignmentNumber = titleAlignmentNumber
        self.titleBackgroundColor = titleBackgroundColor
        self.titleBorderColorHex = titleBorderColorHex
        self.titleBorderSize = titleBorderSize
        self.titleFontName = titleFontName
        self.titleTextColorHex = titleTextColorHex
        self.titleTextSize = titleTextSize
        self.imagePathAWS = imagePathAWS
        self.isUniversal = isUniversal
        self.isDeletable = isDeletable
        self.tempSelectedImage = tempSelectedImage
        self.newSelectedThemeImageTempDirPath = newSelectedThemeImageTempDirPath
        self.newSelectedSheetImageTempDirPath = newSelectedSheetImageTempDirPath
        self.newSelectedThemeImageThumbTempDirPath = newSelectedThemeImageThumbTempDirPath
        self.newSelectedSheetImageThumbTempDirPath = newSelectedSheetImageThumbTempDirPath
        self.isThemeImageDeleted = isThemeImageDeleted
        self.isSheetImageDeleted = isSheetImageDeleted
    }
    
    init?(managedObject: NSManagedObject, context: NSManagedObjectContext) {
        guard let entity = managedObject as? Theme else { return nil }
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
        allHaveTitle = entity.allHaveTitle
        
        backgroundColor = entity.backgroundColor
        backgroundTransparancyNumber = entity.backgroundTransparancyNumber
        displayTime = entity.displayTime
        hasEmptySheet = entity.hasEmptySheet
        imagePath = entity.imagePath
        imagePathThumbnail = entity.imagePathThumbnail
        isEmptySheetFirst = entity.isEmptySheetFirst
        isHidden = entity.isHidden
        isContentBold = entity.isContentBold
        isContentItalic = entity.isContentItalic
        isContentUnderlined = entity.isContentUnderlined
        isTitleBold = entity.isTitleBold
        isTitleItalic = entity.isTitleItalic
        isTitleUnderlined = entity.isTitleUnderlined
        contentAlignmentNumber = entity.contentAlignmentNumber
        contentBorderColorHex = entity.contentBorderColorHex
        contentBorderSize = entity.contentBorderSize
        contentFontName = entity.contentFontName
        contentTextColorHex = entity.contentTextColorHex
        contentTextSize = entity.contentTextSize
        position = entity.position
        titleAlignmentNumber = entity.titleAlignmentNumber
        titleBackgroundColor = entity.titleBackgroundColor
        titleBorderColorHex = entity.titleBorderColorHex
        titleBorderSize = entity.titleBorderSize
        titleFontName = entity.titleFontName
        titleTextColorHex = entity.titleTextColorHex
        titleTextSize = entity.titleTextSize
        imagePathAWS = entity.imagePathAWS
        isUniversal = entity.isUniversal
        isDeletable = entity.isDeletable
    }
    
    func getManagedObjectFrom(_ context: NSManagedObjectContext) -> NSManagedObject {
        
        if let entity: Theme = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity, context: context)
            return entity
        } else {
            let entity: Theme = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity, context: context)
            return entity
        }
    }
    
    private func setPropertiesTo(_ entity: Theme, context: NSManagedObjectContext) {
        entity.id = id
        entity.userUID = userUID
        entity.title = title
        entity.createdAt = createdAt.nsDate
        entity.updatedAt = updatedAt?.nsDate
        entity.deleteDate = deleteDate?.nsDate
        entity.rootDeleteDate = rootDeleteDate?.nsDate

        entity.allHaveTitle = allHaveTitle
        entity.backgroundColor = backgroundColor
        entity.backgroundTransparancyNumber = backgroundTransparancyNumber
        entity.displayTime = displayTime
        entity.hasEmptySheet = hasEmptySheet
        entity.imagePath = imagePath
        entity.imagePathThumbnail = imagePathThumbnail
        entity.isEmptySheetFirst = isEmptySheetFirst
        entity.isHidden = isHidden
        entity.isContentBold = isContentBold
        entity.isContentItalic = isContentItalic
        entity.isContentUnderlined = isContentUnderlined
        entity.isTitleBold = isTitleBold
        entity.isTitleItalic = isTitleItalic
        entity.isTitleUnderlined = isTitleUnderlined
        entity.contentAlignmentNumber = contentAlignmentNumber
        entity.contentBorderColorHex = contentBorderColorHex
        entity.contentBorderSize = contentBorderSize
        entity.contentFontName = contentFontName
        entity.contentTextColorHex = contentTextColorHex
        entity.contentTextSize = contentTextSize
        entity.position = position
        entity.titleAlignmentNumber = titleAlignmentNumber
        entity.titleBackgroundColor = titleBackgroundColor
        entity.titleBorderColorHex = titleBorderColorHex
        entity.titleBorderSize = titleBorderSize
        entity.titleFontName = titleFontName
        entity.titleTextColorHex = titleTextColorHex
        entity.titleTextSize = titleTextSize
        entity.imagePathAWS = imagePathAWS
        entity.isUniversal = isUniversal
        entity.isDeletable = isDeletable
        entity.position = position
    }

    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date().localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var rootDeleteDate: Date? = nil
    
    var allHaveTitle: Bool = false
    var backgroundColor: String? = nil
    var backgroundTransparancyNumber: Double = 0
    var displayTime: Bool = false
    var hasEmptySheet: Bool = false
    var imagePath: String? = nil
    var imagePathThumbnail: String? = nil
    var isEmptySheetFirst: Bool = false
    var isHidden: Bool = false
    var isContentBold: Bool = false
    var isContentItalic: Bool = false
    var isContentUnderlined: Bool = false
    var isTitleBold: Bool = false
    var isTitleItalic: Bool = false
    var isTitleUnderlined: Bool = false
    var contentAlignmentNumber: Int16 = 0
    var contentBorderColorHex: String? = nil
    var contentBorderSize: Float = 0
    var contentFontName: String? = "Avenir"
    var contentTextColorHex: String? = "000000"
    var contentTextSize: Float = 9
    var position: Int16 = 0
    var titleAlignmentNumber: Int16 = 0
    var titleBackgroundColor: String? = nil
    var titleBorderColorHex: String? = nil
    var titleBorderSize: Float = 0
    var titleFontName: String? = "Avenir"
    var titleTextColorHex: String? = "000000"
    var titleTextSize: Float = 11
    var imagePathAWS: String? = nil
    var isUniversal: Bool = false
    var isDeletable: Bool = true
    var tempSelectedImage: UIImage?
    var tempSelectedImageThumbnail: UIImage? {
        tempSelectedImage?.resized(withPercentage: 0.5)
    }
    var newSelectedThemeImageTempDirPath: String? = nil
    var newSelectedSheetImageTempDirPath: String? = nil
    var newSelectedThemeImageThumbTempDirPath: String? = nil
    var newSelectedSheetImageThumbTempDirPath: String? = nil
    var isThemeImageDeleted: Bool = false
    var isSheetImageDeleted: Bool = false
    
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
    
    enum CodingKeysTheme:String,CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate

        case allHaveTitle
        case backgroundColor
        case backgroundTransparancyNumber = "backgroundTransparancy"
        case displayTime
        case hasEmptySheet
        case imagePath
        case imagePathThumbnail
        case isEmptySheetFirst
        case isHidden
        case isContentBold
        case isContentItalic
        case isContentUnderlined
        case isTitleBold
        case isTitleItalic
        case isTitleUnderlined
        case contentAlignment  = "contentAlignmentNumber"
        case contentBorderColorHex = "contentBorderColor"
        case contentBorderSize
        case contentFontName
        case contentTextColorHex = "contentTextColor"
        case contentTextSize
        case position
        case titleAlignment = "titleAlignmentNumber"
        case titleBackgroundColor
        case titleBorderColorHex = "titleBorderColor"
        case titleBorderSize
        case titleFontName
        case titleTextColorHex = "titleTextColor"
        case titleTextSize
        case imagePathAWS
        case isUniversal
        case isDeletable
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysTheme.self)
        try container.encode(id, forKey: .id)
        try container.encode(Int(truncating: NSNumber(value: allHaveTitle)), forKey: .allHaveTitle)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(backgroundTransparancyNumber.description, forKey: .backgroundTransparancyNumber)
        try container.encode(Int(truncating: NSNumber(value: displayTime)), forKey: .displayTime)
        try container.encode(Int(truncating: NSNumber(value: hasEmptySheet)), forKey: .hasEmptySheet)
        try container.encode(Int(truncating: NSNumber(value: isEmptySheetFirst)), forKey: .isEmptySheetFirst)
        try container.encode(Int(truncating: NSNumber(value: isHidden)), forKey: .isHidden)
        try container.encode(Int(truncating: NSNumber(value: isContentBold)), forKey: .isContentBold)
        try container.encode(Int(truncating: NSNumber(value: isContentItalic)), forKey: .isContentItalic)
        try container.encode(Int(truncating: NSNumber(value: isContentUnderlined)), forKey: .isContentUnderlined)
        try container.encode(Int(truncating: NSNumber(value: isTitleBold)), forKey: .isTitleBold)
        try container.encode(Int(truncating: NSNumber(value: isTitleItalic)), forKey: .isTitleItalic)
        try container.encode(Int(truncating: NSNumber(value: isTitleUnderlined)), forKey: .isTitleUnderlined)
        try container.encode(contentAlignmentNumber, forKey: .contentAlignment)
        try container.encode(contentBorderColorHex, forKey: .contentBorderColorHex)
        try container.encode(contentBorderSize, forKey: .contentBorderSize)
        try container.encode(contentFontName, forKey: .contentFontName)
        try container.encode(contentTextColorHex, forKey: .contentTextColorHex)
        try container.encode(contentTextSize, forKey: .contentTextSize)
        try container.encode(position, forKey: .position)
        try container.encode(titleAlignmentNumber, forKey: .titleAlignment)
        try container.encode(titleBackgroundColor, forKey: .titleBackgroundColor)
        try container.encode(titleBorderColorHex, forKey: .titleBorderColorHex)
        try container.encode(titleBorderSize, forKey: .titleBorderSize)
        try container.encode(titleFontName, forKey: .titleFontName)
        try container.encode(titleTextColorHex, forKey: .titleTextColorHex)
        try container.encode(titleTextSize, forKey: .titleTextSize)
        try container.encode(imagePathAWS, forKey: .imagePathAWS)
        try container.encode(Int(truncating: NSNumber(value: isDeletable)), forKey: .isDeletable)
        
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysTheme.self)
        allHaveTitle = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .allHaveTitle) ?? 0) as NSNumber)
        backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
        let transparencyString = try container.decodeIfPresent(String.self, forKey: .backgroundTransparancyNumber) ?? ""
        backgroundTransparancyNumber = Double(truncating: NSDecimalNumber(decimal:Decimal(string: transparencyString) ?? 0.0))
        displayTime = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .displayTime) ?? 0) as NSNumber)
        hasEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .hasEmptySheet) ?? 0) as NSNumber)
        isEmptySheetFirst = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isEmptySheetFirst) ?? 0) as NSNumber)
        isHidden = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isHidden) ?? 0) as NSNumber)
        isContentBold = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentBold) ?? 0) as NSNumber)
        isContentItalic = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentItalic) ?? 0) as NSNumber)
        isContentUnderlined = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentUnderlined) ?? 0) as NSNumber)
        isTitleBold = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleBold) ?? 0) as NSNumber)
        isTitleItalic = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleItalic) ?? 0) as NSNumber)
        isTitleUnderlined = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleUnderlined) ?? 0) as NSNumber)
        contentAlignmentNumber = try container.decodeIfPresent(Int16.self, forKey: .contentAlignment) ?? 0
        contentBorderColorHex = try container.decodeIfPresent(String.self, forKey: .contentBorderColorHex)
        contentBorderSize = try container.decodeIfPresent(Float.self, forKey: .contentBorderSize) ?? 14
        contentFontName = try container.decodeIfPresent(String.self, forKey: .contentFontName)
        contentTextColorHex = try container.decodeIfPresent(String.self, forKey: .contentTextColorHex)
        contentTextSize = try container.decodeIfPresent(Float.self, forKey: .contentTextSize) ?? 14
        position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
        titleAlignmentNumber = try container.decodeIfPresent(Int16.self, forKey: .titleAlignment) ?? 0
        titleBackgroundColor = try container.decodeIfPresent(String.self, forKey: .titleBackgroundColor)
        titleBorderColorHex = try container.decodeIfPresent(String.self, forKey: .titleBorderColorHex)
        titleBorderSize = try container.decodeIfPresent(Float.self, forKey: .titleBorderSize) ?? 0
        titleFontName = try container.decodeIfPresent(String.self, forKey: .titleFontName)
        titleTextColorHex = try container.decodeIfPresent(String.self, forKey: .titleTextColorHex)
        titleTextSize = try container.decodeIfPresent(Float.self, forKey: .titleTextSize) ?? 14
        imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
        isUniversal = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isUniversal) ?? 0) as NSNumber)
        isDeletable = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isDeletable) ?? 0) as NSNumber)
        
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
    
}

extension ThemeCodable: FileTransferable {
    
    func getDeleteObjects(forceDelete: Bool) -> [String] {
        var fileNames: [String?] = []
        if isThemeImageDeleted || forceDelete {
            fileNames.append(imagePathAWS)
        }
        return fileNames.compactMap { $0 }
    }
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
        if isThemeImageDeleted || forceDelete {
            imagePathAWS = nil
            // remove locally saved images
            _ = try? UIImage.set(image: nil, imageName: imagePath, thumbNailName: imagePathThumbnail)
            imagePath = nil
            imagePathThumbnail = nil
        }
    }
    
    var uploadObjects: [TransferObject] {
        [newSelectedThemeImageTempDirPath, newSelectedSheetImageTempDirPath].compactMap { $0 }.compactMap { UploadObject(fileName: $0) }
    }
    
    var downloadObjects: [TransferObject] {
        [self].filter({ $0.hasNewRemoteImage }).compactMap({ URL(string: $0.imagePathAWS) }).compactMap({ DownloadObject(remoteURL: $0) })
    }
    
    
    var transferObjects: [TransferObject] {
        uploadObjects + downloadObjects
    }
    
    mutating func setTransferObjects(_ transferObjects: [TransferObject]) throws {
        let uploadObjects = transferObjects.compactMap { $0 as? UploadObject }
        for uploadObject in uploadObjects {
            if newSelectedThemeImageTempDirPath == uploadObject.fileName {
                imagePathAWS = uploadObject.fileName
                if let image = UIImage.getFromTempDir(imagePath: uploadObject.fileName) {
                    let savedImage = try UIImage.set(image: image, imageName: uploadObject.fileName, thumbNailName: nil)
                    imagePath = savedImage.imagePath
                    imagePathThumbnail = savedImage.thumbPath
                }
                try FileManager.deleteTempFile(name: uploadObject.fileName)
            }
            if newSelectedSheetImageTempDirPath == uploadObject.fileName {
                imagePathAWS = uploadObject.fileName
                if let image = UIImage.getFromTempDir(imagePath: uploadObject.fileName) {
                    let savedImage = try UIImage.set(image: image, imageName: uploadObject.fileName, thumbNailName: nil)
                    imagePath = savedImage.imagePath
                    imagePathThumbnail = savedImage.thumbPath
                }
                try FileManager.deleteTempFile(name: uploadObject.fileName)
            }
        }
        for download in downloadObjects.compactMap({ $0 as? DownloadObject }) {
            if imagePathAWS == download.remoteURL.absoluteString {
                try setBackgroundImage(image: download.image, imageName: download.filename)
            }
        }
    }
    
    func setDeleteDate() -> FileTransferable {
        var modifiedDocument = self
        if uploadSecret != nil {
            modifiedDocument.rootDeleteDate = Date()
        } else {
            modifiedDocument.deleteDate = Date()
        }
        return modifiedDocument
    }
    
    func setUpdatedAt() -> FileTransferable {
        var modifiedDocument = self
        modifiedDocument.updatedAt = Date()
        return modifiedDocument
    }
    
    func setUserUID() throws -> FileTransferable {
        var modifiedDocument = self
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        modifiedDocument.userUID = userUID
        return modifiedDocument
    }
    
    private mutating func setBackgroundImage(image: UIImage?, imageName: String?) throws {
        let savedImage = try UIImage.set(image: image, imageName: imageName ?? self.imagePath, thumbNailName: self.imagePathThumbnail)
        self.imagePath = savedImage.imagePath
        self.imagePathThumbnail = savedImage.thumbPath
    }
}
