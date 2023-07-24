//
//  SheetPastorsCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData
import UIKit

public struct SheetPastorsCodable: EntityCodableType, SheetMetaType {
    
    static func makeDefault() -> SheetPastorsCodable {
        SheetPastorsCodable(title: "Pastor John and Jessy Doe", content: "Pastoring in Almere city")
    }
    init?(entity: SheetPastorsEntity) {
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
        
        isEmptySheet = entity.isEmptySheet
        position = entity.position.intValue
        time = entity.time
        
        content = entity.content
        imagePath = entity.imagePath
        thumbnailPath = entity.thumbnailPath
        imagePathAWS = entity.imagePathAWS
        
        uiImage = imagePath?.loadImage()
        uiImageThumb = thumbnailPath?.loadImage()
    }
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString,
         userUID: String = "",
         title: String? = nil,
         createdAt: Date = Date.localDate(),
         updatedAt: Date? = nil,
         deleteDate: Date? = nil,
         isTemp: Bool = false,
         rootDeleteDate: Date? = nil,
         isEmptySheet: Bool = false,
         position: Int = 0,
         time: Double = 0,
         hasTheme: ThemeCodable? = nil,
         content: String? = nil,
         imagePath: String? = nil,
         thumbnailPath: String? = nil,
         imagePathAWS: String? = nil,
         newSelectedSheetImageTempDirPath: String? = nil,
         isSheetImageDeleted: Bool = false
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
        self.imagePath = imagePath
        self.thumbnailPath = thumbnailPath
        self.imagePathAWS = imagePathAWS
        
        self.newSelectedSheetImageTempDirPath = newSelectedSheetImageTempDirPath
        self.isSheetImageDeleted = isSheetImageDeleted
    }
        
    static var type: SheetType = .SheetPastors
    var sheetType: SheetType {
        .SheetPastors
    }
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
    var isEmptySheet = false
    var position: Int = 0
    var time: Double = 0
    var hasTheme: ThemeCodable? = nil
    
    var content: String? = nil
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysPastors.self)
        
        content = try container.decodeIfPresent(String.self, forKey: .content)
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
        var container = encoder.container(keyedBy: CodingKeysPastors.self)
        
        try container.encode(content, forKey: .content)
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

extension SheetPastorsCodable: FileTransferable {
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
        if isSheetImageDeleted || forceDelete {
            imagePathAWS = nil
            // remove locally saved images
            
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
            if imagePathAWS == download.filename || URL(string: imagePathAWS)?.pathComponents.last == download.filename {
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
        if let image {
            let imagePath = try SaveImageUseCase().saveImage(image: image, isThumb: false)
            self.imagePath = imagePath
            thumbnailPath = try SaveImageUseCase().createThumbAndSave(fileName: imagePath)
        }
    }

}

