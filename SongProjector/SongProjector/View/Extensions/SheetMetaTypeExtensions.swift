//
//  SheetMetaTypeExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit

extension SheetMetaType {
    
    func getTransferObjects() -> [TransferObject] {
        if var sheetTitleContentCodable = self as? SheetTitleContentCodable {
            return sheetTitleContentCodable.transferObjects
        } else if var sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.transferObjects
        } else if var sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.transferObjects
        } else if var sheetTitleContentCodable = self as? SheetEmptyCodable {
            return sheetTitleContentCodable.transferObjects
        }else if var sheetTitleContentCodable = self as? SheetEmptyCodable {
            return sheetTitleContentCodable.transferObjects
        }
        return []
    }
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
        if var sheet = self as? SheetTitleImageCodable {
            return sheet.clearDataForDeletedObjects(forceDelete: forceDelete)
        } else if var sheet = self as? SheetPastorsCodable {
            return sheet.clearDataForDeletedObjects(forceDelete: forceDelete)
        }
    }
    
    func set(theme: ThemeCodable) -> SheetMetaType {
        if var sheet = self as? SheetTitleContentCodable {
            sheet.hasTheme = theme
            return sheet
        } else if var sheet = self as? SheetTitleImageCodable {
            sheet.hasTheme = theme
            return sheet
        } else if var sheet = self as? SheetPastorsCodable {
            sheet.hasTheme = theme
            return sheet
        } else if var sheet = self as? SheetEmptyCodable {
            sheet.hasTheme = theme
            return sheet
        } else if var sheet = self as? SheetSplitCodable {
            sheet.hasTheme = theme
            return sheet
        }
        return self
    }
    
    var theme: ThemeCodable? {
        if let sheetTitleContentCodable = self as? SheetTitleContentCodable {
            return sheetTitleContentCodable.hasTheme
        } else if let sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.hasTheme
        } else if let sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.hasTheme
        } else if let sheetEmpty = self as? SheetEmptyCodable {
            return sheetEmpty.hasTheme
        }
        return nil
    }
    
    var isBibleVers: Bool {
        if let sheetTitleContentCodable = self as? SheetTitleContentCodable {
            return sheetTitleContentCodable.isBibleVers
        }
        if let sheet = self as? SheetEmptyCodable {
            return sheet.hasTheme == nil
        }
        return false
    }

    var sheetContent: String? {
        if let sheetTitleContentCodable = self as? SheetTitleContentCodable {
            return sheetTitleContentCodable.content
        } else if let sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.content
        } else if let sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.content
        } else if let sheetSplit = self as? SheetSplitCodable {
            return sheetSplit.textLeft
        }
        return nil
    }
    
    var deleteObjects: [DeleteObject] {
        if let sheet = self as? SheetTitleContentCodable {
            let deleteObject = DeleteObject(
                imagePathAWS: sheet.hasTheme?.imagePathAWS,
                imagePath: sheet.hasTheme?.imagePath,
                thumbnailPath: sheet.hasTheme?.imagePathThumbnail
            )
            return [deleteObject]
        } else if let sheet = self as? SheetTitleImageCodable {
            let deleteObject = DeleteObject(
                imagePathAWS: sheet.hasTheme?.imagePathAWS,
                imagePath: sheet.hasTheme?.imagePath,
                thumbnailPath: sheet.hasTheme?.imagePathThumbnail
            )
            let deleteObject2 = DeleteObject(
                imagePathAWS: sheet.imagePathAWS,
                imagePath: sheet.imagePath,
                thumbnailPath: sheet.thumbnailPath
            )
            return [deleteObject, deleteObject2]
        } else if let sheet = self as? SheetPastorsCodable {
            let deleteObject = DeleteObject(
                imagePathAWS: sheet.hasTheme?.imagePathAWS,
                imagePath: sheet.hasTheme?.imagePath,
                thumbnailPath: sheet.hasTheme?.imagePathThumbnail
            )
            let deleteObject2 = DeleteObject(
                imagePathAWS: sheet.imagePathAWS,
                imagePath: sheet.imagePath,
                thumbnailPath: sheet.thumbnailPath
            )
            return [deleteObject, deleteObject2]
        } else if let sheet = self as? SheetSplitCodable {
            let deleteObject = DeleteObject(
                imagePathAWS: sheet.hasTheme?.imagePathAWS,
                imagePath: sheet.hasTheme?.imagePath,
                thumbnailPath: sheet.hasTheme?.imagePathThumbnail
            )
            return [deleteObject]
        } else if let sheet = self as? SheetEmptyCodable {
            let deleteObject = DeleteObject(
                imagePathAWS: sheet.hasTheme?.imagePathAWS,
                imagePath: sheet.hasTheme?.imagePath,
                thumbnailPath: sheet.hasTheme?.imagePathThumbnail
            )
            return [deleteObject]
        }
        return []
    }
    
    var sheetImagePath: String? {
        if let sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.imagePath
        } else if let sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.imagePath
        }
        return nil
    }
    
    var sheetImageThumbnailPath: String? {
        if let sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.thumbnailPath
        } else if let sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.thumbnailPath
        }
        return nil
    }
    
    
    var sheetImage: UIImage? {
        if let sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.uiImage
        } else if let sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.uiImage
        }
        return nil
    }
    
    var sheetImageThumbnail: UIImage? {
        if let sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.uiImageThumb
        } else if let sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.uiImageThumb
        }
        return nil
    }
    
    var themeBackgroundImage: UIImage? {
        theme?.backgroundImage
    }
    
    var themeBackgroundImageThumbnail: UIImage? {
        theme?.thumbnail
    }
    
    var sheetTime: Double? {
        if let sheetTitleContentCodable = self as? SheetTitleContentCodable {
            return sheetTitleContentCodable.time
        } else if let sheetTitleImageCodable = self as? SheetTitleImageCodable {
            return sheetTitleImageCodable.time
        } else if let sheetPastors = self as? SheetPastorsCodable {
            return sheetPastors.time
        } else if let sheetSplit = self as? SheetSplitCodable {
            return sheetSplit.time
        }
        return nil
    }
    
}

extension Array where Element == SheetMetaType {
    
    func updateWith(downloadObjects: [DownloadObject]) throws -> [SheetMetaType] {
        var sheets: [SheetMetaType] = []
        for sheet in self {
            if var changeableSheet = sheet as? SheetTitleContentCodable {
                if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == changeableSheet.hasTheme?.imagePathAWS }) {
                    let savedImageInfo = try UIImage.set(image: downloadObject.image, imageName: downloadObject.filename, thumbNailName: nil)
                    changeableSheet.hasTheme?.imagePath = savedImageInfo.imagePath
                    changeableSheet.hasTheme?.imagePathThumbnail = savedImageInfo.thumbPath
                }
                sheets.append(changeableSheet)
            } else if var changeableSheet = sheet as? SheetTitleImageCodable {
                if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == changeableSheet.hasTheme?.imagePathAWS }) {
                    let savedImageInfo = try UIImage.set(image: downloadObject.image, imageName: downloadObject.filename, thumbNailName: nil)
                    changeableSheet.hasTheme?.imagePath = savedImageInfo.imagePath
                    changeableSheet.hasTheme?.imagePathThumbnail = savedImageInfo.thumbPath
                }
                if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == changeableSheet.imagePathAWS }) {
                    let savedImageInfo = try UIImage.set(image: downloadObject.image, imageName: downloadObject.filename, thumbNailName: nil)
                    changeableSheet.imagePath = savedImageInfo.imagePath
                    changeableSheet.thumbnailPath = savedImageInfo.thumbPath
                }
                
                sheets.append(changeableSheet)
            } else if var changeableSheet = sheet as? SheetPastorsCodable {
                if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == changeableSheet.hasTheme?.imagePathAWS }) {
                    let savedImageInfo = try UIImage.set(image: downloadObject.image, imageName: downloadObject.filename, thumbNailName: nil)
                    changeableSheet.hasTheme?.imagePath = savedImageInfo.imagePath
                    changeableSheet.hasTheme?.imagePathThumbnail = savedImageInfo.thumbPath
                }
                if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == changeableSheet.imagePathAWS }) {
                    let savedImageInfo = try UIImage.set(image: downloadObject.image, imageName: downloadObject.filename, thumbNailName: nil)
                    changeableSheet.imagePath = savedImageInfo.imagePath
                    changeableSheet.thumbnailPath = savedImageInfo.thumbPath
                }
                sheets.append(changeableSheet)
            } else if var changeableSheet = sheet as? SheetEmptyCodable {
                if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == changeableSheet.hasTheme?.imagePathAWS }) {
                    let savedImageInfo = try UIImage.set(image: downloadObject.image, imageName: downloadObject.filename, thumbNailName: nil)
                    changeableSheet.hasTheme?.imagePath = savedImageInfo.imagePath
                    changeableSheet.hasTheme?.imagePathThumbnail = savedImageInfo.thumbPath
                }
                sheets.append(changeableSheet)
            } else if var changeableSheet = sheet as? SheetSplitCodable {
                if let downloadObject = downloadObjects.first(where: { $0.remoteURL.absoluteString == changeableSheet.hasTheme?.imagePathAWS }) {
                    let savedImageInfo = try UIImage.set(image: downloadObject.image, imageName: downloadObject.filename, thumbNailName: nil)
                    changeableSheet.hasTheme?.imagePath = savedImageInfo.imagePath
                    changeableSheet.hasTheme?.imagePathThumbnail = savedImageInfo.thumbPath
                }
                sheets.append(changeableSheet)
            } else {
                sheets.append(sheet)
            }
            
        }
        return sheets
    }
    
}

extension Array where Element == SheetMetaType {
    
    var downloadObjects: [TransferObject] {
        let sheetDownloadObjects = self.map { sheet in
            if let sheetTitleContentCodable = sheet as? SheetTitleContentCodable {
                return sheetTitleContentCodable.downloadObjects as [TransferObject]
            } else if let sheetTitleImageCodable = sheet as? SheetTitleImageCodable {
                return sheetTitleImageCodable.downloadObjects as [TransferObject]
            } else if let sheetPastors = sheet as? SheetPastorsCodable {
                return sheetPastors.downloadObjects as [TransferObject]
            } else if let sheetTitleContentCodable = sheet as? SheetEmptyCodable {
                return sheetTitleContentCodable.downloadObjects as [TransferObject]
            }else if let sheetTitleContentCodable = sheet as? SheetEmptyCodable {
                return sheetTitleContentCodable.downloadObjects as [TransferObject]
            } else {
                let empty = [TransferObject]()
                return empty
            }
        }
        return self.map { $0.theme?.downloadObjects ?? [] }.flatMap { $0 } + sheetDownloadObjects.flatMap { $0 }
    }
    
    var uploadObjects: [TransferObject] {
        let sheetUploadObjects = self.map { sheet in
            if let sheetTitleContentCodable = sheet as? SheetTitleContentCodable {
                return sheetTitleContentCodable.uploadObjects
            } else if let sheetTitleImageCodable = sheet as? SheetTitleImageCodable {
                return sheetTitleImageCodable.uploadObjects
            } else if let sheetPastors = sheet as? SheetPastorsCodable {
                return sheetPastors.uploadObjects
            } else if let sheetTitleContentCodable = sheet as? SheetEmptyCodable {
                return sheetTitleContentCodable.uploadObjects
            }else if let sheetTitleContentCodable = sheet as? SheetEmptyCodable {
                return sheetTitleContentCodable.uploadObjects
            } else {
                let empty: [TransferObject] = []
                return empty
            }
        }.flatMap { $0 }
        return self.map { $0.theme?.uploadObjects ?? [] }.flatMap { $0 } + sheetUploadObjects
    }
    
    var deleteObjects: [String] {
        uploadObjects
            .compactMap { $0 as? UploadObject }
            .compactMap { $0.remoteURL?.absoluteString }
            .compactMap { $0 }
    }
    
    
    func setObjects(transferObjects: [TransferObject]) throws -> [SheetMetaType] {
        try self.map { sheet in
            if var sheetTitleContentCodable = sheet as? SheetTitleContentCodable {
                try sheetTitleContentCodable.setTransferObjects(transferObjects)
                return sheetTitleContentCodable
            } else if var sheetTitleImageCodable = sheet as? SheetTitleImageCodable {
                try sheetTitleImageCodable.setTransferObjects(transferObjects)
                return sheetTitleImageCodable
            } else if var sheetPastors = sheet as? SheetPastorsCodable {
                try sheetPastors.setTransferObjects(transferObjects)
                return sheetPastors
            } else if var sheetEmpty = sheet as? SheetEmptyCodable {
                try sheetEmpty.setTransferObjects(transferObjects)
                return sheetEmpty
            }
            return sheet
        }
    }
}
