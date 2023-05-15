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
