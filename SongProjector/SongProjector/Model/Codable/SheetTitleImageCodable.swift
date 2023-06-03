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
import UIKit

public struct SheetTitleImageCodable: EntityCodableType, SheetMetaType {
    
    static func makeDefault() async throws -> SheetTitleImageCodable? {
#if DEBUG
        let userId = "userid"
#else
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
#endif
        
        return SheetTitleImageCodable(
            id: "CHURCHBEAM" + UUID().uuidString,
            userUID: userId,
            title: "Title image sheet",
            createdAt: Date(),
            updatedAt: Date(),
            deleteDate: nil,
            rootDeleteDate: nil,
            isEmptySheet: false,
            position: 0,
            time: 0,
            hasTheme: try await ThemeCodable.makeDefault(isHidden: true),
            content: "Content image sheet",
            hasTitle: false,
            imageBorderColor: nil,
            imageBorderSize: 0,
            imageContentMode: 0,
            imageHasBorder: false,
            imagePath: nil,
            thumbnailPath: nil,
            imagePathAWS: nil,
            newSelectedSheetImageTempDirPath: nil,
            isSheetImageDeleted: false
        )
    }
    
    static var type: SheetType = .SheetTitleImage
    var sheetType: SheetType {
        .SheetTitleImage
    }
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
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
    
    var uiImage: UIImage?
    var uiImageThumb: UIImage?
    
    var newSelectedSheetImageTempDirPath: String? = nil
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
        imagePathAWS: String?,
        newSelectedSheetImageTempDirPath: String? = nil,
        isSheetImageDeleted: Bool = false
    ) {
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
        self.newSelectedSheetImageTempDirPath = newSelectedSheetImageTempDirPath
        self.isSheetImageDeleted = isSheetImageDeleted
    }
    
    init?(entity: SheetTitleImageEntity) {
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
        content = entity.content
        hasTitle = entity.hasTitle
        imageBorderColor = entity.imageBorderColor
        imageBorderSize = entity.imageBorderSize
        imageContentMode = entity.imageContentMode
        imageHasBorder = entity.imageHasBorder
        imagePath = entity.imagePath
        thumbnailPath = entity.thumbnailPath
        imagePathAWS = entity.imagePathAWS
        
        uiImage = imagePath?.loadImage()
        uiImageThumb = thumbnailPath?.loadImage()
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
        position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
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

extension SheetTitleImageCodable: FileTransferable {
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
        if isSheetImageDeleted || forceDelete {
            imagePathAWS = nil
            
            try? DeleteFileAtURLUseCase(fileName: imagePath)?.delete()
            try? DeleteFileAtURLUseCase(fileName: thumbnailPath)?.delete()
            imagePath = nil
            thumbnailPath = nil
        }
    }
    
    func getDeleteObjects(forceDelete: Bool) -> [DeleteObject] {
        let deleteObjects = hasTheme?.getDeleteObjects(forceDelete: forceDelete) ?? []
        
        let deleteObject2 = DeleteObject(
            imagePathAWS: imagePathAWS,
            imagePath: imagePath,
            imagePathThumbnail: thumbnailPath
        )
        return deleteObjects + [deleteObject2]
    }
    
    var uploadObjects: [TransferObject] {
        [newSelectedSheetImageTempDirPath].compactMap { $0 }.compactMap { UploadObject(fileName: $0) } + [hasTheme].compactMap { $0?.newSelectedThemeImageTempDirPath }.compactMap { UploadObject(fileName: $0) }
    }
    
    var downloadObjects: [TransferObject] {
        [self].filter({ $0.hasNewRemoteImage }).compactMap({ URL(string: $0.imagePathAWS) }).compactMap({ DownloadObject(remoteURL: $0) }) + [self].compactMap { $0.hasTheme?.imagePathAWS }.compactMap { URL(string: $0) }.compactMap { DownloadObject(remoteURL: $0)}
    }
    
    var transferObjects: [TransferObject] {
        uploadObjects + downloadObjects
    }
    
    mutating func setTransferObjects(_ transferObjects: [TransferObject]) throws {
        let uploadObjects = transferObjects.compactMap { $0 as? UploadObject }
        for uploadObject in uploadObjects {
            if newSelectedSheetImageTempDirPath == uploadObject.fileName {
                imagePathAWS = uploadObject.fileName
                imagePath = try MoveImageUseCase().moveImageFromTempToNewPersistantDirectory(uploadObject.fileName)
                thumbnailPath = try SaveImageUseCase().createThumbAndSave(fileName: uploadObject.fileName)
                newSelectedSheetImageTempDirPath = nil
            }
        }
        
        var theme = hasTheme
        try theme?.setTransferObjects(transferObjects)
        self.hasTheme = theme
        
        for download in transferObjects.compactMap({ $0 as? DownloadObject }) {
            if imagePathAWS == download.filename {
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
        modifiedDocument.updatedAt = Date.localDate()
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
        if let image {
            let imagePath = try SaveImageUseCase().saveImage(image: image, isThumb: false)
            self.imagePath = imagePath
            thumbnailPath = try SaveImageUseCase().createThumbAndSave(fileName: imagePath)
        }
    }
}
