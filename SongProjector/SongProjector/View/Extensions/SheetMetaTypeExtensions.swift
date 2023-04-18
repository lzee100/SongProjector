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
    
    var themeBackgroundImage: UIImage? {
        theme?.backgroundImage
    }
    
    var themeBackgroundImageThumbnail: UIImage? {
        theme?.thumbnail
    }
}
