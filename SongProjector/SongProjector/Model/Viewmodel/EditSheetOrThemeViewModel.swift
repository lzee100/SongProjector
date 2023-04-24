//
//  EditSheetOrThemeswift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseAuth

struct EditSheetOrThemeViewModel {
    
    enum EditMode {
        case theme(ThemeCodable?)
        case sheet(SheetMetaType?, sheetType: SheetType)
        
        var isSheet: Bool {
            switch self {
            case .sheet: return true
            case .theme: return false
            }
        }
    }
    
    let isNewEntity: Bool
    let editMode: EditMode
    let theme: ThemeCodable
    let sheet: SheetMetaType
    let sheetType: SheetType
    
    var requestMethod: RequestMethod {
        isNewEntity ? .post : .put
    }
    
    var allHaveTitle: Bool
    var backgroundColor: Color
    var backgroundTransparancyNumber: Double
    var displayTime: Bool
    var hasEmptySheet: Bool
    var imagePath: String?
    var imagePathThumbnail: String?
    var isEmptySheetFirst: Bool
    var isHidden: Bool
    var isContentBold: Bool
    var isContentItalic: Bool
    var isContentUnderlined: Bool
    var isTitleBold: Bool
    var isTitleItalic: Bool
    var isTitleUnderlined: Bool
    var contentAlignmentNumber: Int16
    var contentBorderColorHex: String?
    var contentBorderSize: Float
    var contentFontName: String?
    var contentTextColorHex: String?
    var contentTextSize: Float
    var position: Int16
    var titleAlignmentNumber: Int16
    var titleBackgroundColor: String?
    var titleBorderColorHex: String?
    var titleBorderSize: Float
    var titleFontName: String?
    var titleTextColorHex: String?
    var titleTextSize: Float
    var imagePathAWS: String?
    var isUniversal: Bool
    var isDeletable: Bool
    
    // sheet properties
    var title: String = ""
    var sheetContent: String = ""
    var sheetContentRight: String = ""
    var sheetImagePath: String?
    var sheetImagePathThumb: String?
    var sheetImagePathAWS: String?
    
    var uiImageTheme: UIImage?
    var uiImageThumbTheme: UIImage?
    var uiImageSheet: UIImage?
    var uiImageThumbSheet: UIImage?

    var newSelectedThemeImageTempDirPath: String? = nil
    var newSelectedSheetImageTempDirPath: String? = nil
    
    var newSelectedThemeImage: UIImage? // binding
    var newSelectedSheetImage: UIImage? // binding
    private var newSelectedThemeImageThumb: UIImage?
    private var newSelectedSheetImageThumb: UIImage?
    
    var isThemeImageDeleted: Bool = false
    var isSheetImageDeleted: Bool = false
    
    var imageBorderColor: String?
    var imageBorderSize: Int16
    var imageContentMode: Int16
    var imageHasBorder: Bool
    
    init?(editMode: EditMode, isUniversal: Bool, image: UIImage? = nil) {
        self.editMode = editMode
        let theme: ThemeCodable
        switch editMode {
        case .theme(let persitedTheme):
            self.isNewEntity = persitedTheme != nil
            if let extractedTheme = persitedTheme ?? ThemeCodable.makeDefault(), let sheet = SheetTitleContentCodable.makeDefault() {
                theme = extractedTheme
                self.sheet = sheet
                self.sheetType = .SheetTitleContent
            } else {
                return nil
            }
        case .sheet(let sheet, sheetType: let sheetType):
            self.isNewEntity = sheet != nil
            if let sheet = sheet ?? sheetType.makeDefault(), let extractedTheme = sheet.theme ?? ThemeCodable.makeDefault() {
                self.sheet = sheet
                self.sheetType = sheetType
                theme = extractedTheme
            } else {
                return nil
            }
        }
        self.allHaveTitle = theme.allHaveTitle
        self.backgroundColor = theme.backgroundColor?.color ?? .white
        self.backgroundTransparancyNumber = theme.backgroundTransparancyNumber
        self.displayTime = theme.displayTime
        self.hasEmptySheet = theme.hasEmptySheet
        self.imagePath = theme.imagePath
        self.imagePathThumbnail = theme.imagePathThumbnail
        self.isEmptySheetFirst = theme.isEmptySheetFirst
        self.isHidden = theme.isHidden
        self.isContentBold = theme.isContentBold
        self.isContentItalic = theme.isContentItalic
        self.isContentUnderlined = theme.isContentUnderlined
        self.isTitleBold = theme.isTitleBold
        self.isTitleItalic = theme.isTitleItalic
        self.isTitleUnderlined = theme.isTitleUnderlined
        self.contentAlignmentNumber = theme.contentAlignmentNumber
        self.contentBorderColorHex = theme.contentBorderColorHex
        self.contentBorderSize = theme.contentBorderSize
        self.contentFontName = theme.contentFontName
        self.contentTextColorHex = theme.contentTextColorHex
        self.contentTextSize = theme.contentTextSize
        self.position = theme.position
        self.titleAlignmentNumber = theme.titleAlignmentNumber
        self.titleBackgroundColor = theme.titleBackgroundColor
        self.titleBorderColorHex = theme.titleBorderColorHex
        self.titleBorderSize = theme.titleBorderSize
        self.titleFontName = theme.titleFontName
        self.titleTextColorHex = theme.titleTextColorHex
        self.titleTextSize = theme.titleTextSize
        self.imagePathAWS = theme.imagePathAWS
        self.isUniversal = isUniversal
        self.isDeletable = !isUniversal
        
        self.title = sheet.title ?? ""
        self.sheetContent = sheet.sheetContent ?? ""
        
        self.sheetImagePath = sheet.sheetImagePath
        self.sheetImagePathThumb = sheet.sheetImageThumbnailPath
        self.newSelectedSheetImage = image
        self.uiImageTheme = imagePath?.loadImage()
        self.uiImageThumbTheme = imagePathThumbnail?.loadImage()
        self.uiImageSheet = sheetImagePath?.loadImage()
        self.uiImageThumbSheet = sheetImagePathThumb?.loadImage()
        
        if let sheet = sheet as? SheetTitleImageCodable {
            imageBorderColor = sheet.imageBorderColor
            imageBorderSize = sheet.imageBorderSize
            imageContentMode = sheet.imageContentMode
            imageHasBorder = sheet.imageHasBorder
        } else {
            imageBorderColor = nil
            imageBorderSize = 0
            imageContentMode = 0
            imageHasBorder = false
        }
        self.theme = theme
    }
    
    mutating func styleAsTheme(_ theme: Theme) {
        self.allHaveTitle = theme.allHaveTitle
        self.backgroundColor = theme.backgroundColor?.color ?? .white
        self.backgroundTransparancyNumber = theme.backgroundTransparancyNumber
        self.displayTime = theme.displayTime
        self.hasEmptySheet = theme.hasEmptySheet
        self.isEmptySheetFirst = theme.isEmptySheetFirst
        self.isHidden = theme.isHidden
        self.isContentBold = theme.isContentBold
        self.isContentItalic = theme.isContentItalic
        self.isContentUnderlined = theme.isContentUnderlined
        self.isTitleBold = theme.isTitleBold
        self.isTitleItalic = theme.isTitleItalic
        self.isTitleUnderlined = theme.isTitleUnderlined
        self.contentAlignmentNumber = theme.contentAlignmentNumber
        self.contentBorderColorHex = theme.contentBorderColorHex
        self.contentBorderSize = theme.contentBorderSize
        self.contentFontName = theme.contentFontName
        self.contentTextColorHex = theme.contentTextColorHex
        self.contentTextSize = theme.contentTextSize
        self.position = theme.position
        self.titleAlignmentNumber = theme.titleAlignmentNumber
        self.titleBackgroundColor = theme.titleBackgroundColor
        self.titleBorderColorHex = theme.titleBorderColorHex
        self.titleBorderSize = theme.titleBorderSize
        self.titleFontName = theme.titleFontName
        self.titleTextColorHex = theme.titleTextColorHex
        self.titleTextSize = theme.titleTextSize
        
        if let themeBackgroundImage = theme.imagePath?.loadImage() {
            self.newSelectedThemeImage = themeBackgroundImage
        }
    }
    
    mutating func styleAsTheme(_ theme: ThemeCodable) {
        self.allHaveTitle = theme.allHaveTitle
        self.backgroundColor = theme.backgroundColor?.color ?? .white
        self.backgroundTransparancyNumber = theme.backgroundTransparancyNumber
        self.displayTime = theme.displayTime
        self.hasEmptySheet = theme.hasEmptySheet
        self.isEmptySheetFirst = theme.isEmptySheetFirst
        self.isHidden = theme.isHidden
        self.isContentBold = theme.isContentBold
        self.isContentItalic = theme.isContentItalic
        self.isContentUnderlined = theme.isContentUnderlined
        self.isTitleBold = theme.isTitleBold
        self.isTitleItalic = theme.isTitleItalic
        self.isTitleUnderlined = theme.isTitleUnderlined
        self.contentAlignmentNumber = theme.contentAlignmentNumber
        self.contentBorderColorHex = theme.contentBorderColorHex
        self.contentBorderSize = theme.contentBorderSize
        self.contentFontName = theme.contentFontName
        self.contentTextColorHex = theme.contentTextColorHex
        self.contentTextSize = theme.contentTextSize
        self.position = theme.position
        self.titleAlignmentNumber = theme.titleAlignmentNumber
        self.titleBackgroundColor = theme.titleBackgroundColor
        self.titleBorderColorHex = theme.titleBorderColorHex
        self.titleBorderSize = theme.titleBorderSize
        self.titleFontName = theme.titleFontName
        self.titleTextColorHex = theme.titleTextColorHex
        self.titleTextSize = theme.titleTextSize
        
        if let backgroundImage = theme.backgroundImage {
            self.newSelectedThemeImage = backgroundImage
        }
    }
    
    mutating func setNewThemeImage(_ image: UIImage) {
        newSelectedThemeImage = image
        newSelectedThemeImageThumb = image.resized(withPercentage: 0.4)
    }
    
    mutating func deleteNewThemeImage() {
        newSelectedThemeImage = nil
        newSelectedThemeImageThumb = nil
        isThemeImageDeleted = true
    }
    
    func getThemeImage(thumb: Bool) -> UIImage? {
        if isThemeImageDeleted { return nil }
        if thumb {
            return newSelectedThemeImageThumb ?? uiImageThumbTheme
        }
        return newSelectedThemeImage ?? uiImageTheme
    }
    
    mutating func setNewSheetImage(_ image: UIImage) {
        newSelectedSheetImage = image
        newSelectedSheetImageThumb = image.resized(withPercentage: 0.4)
    }
    
    mutating func deleteNewSheetImage() {
        newSelectedSheetImage = nil
        newSelectedSheetImageThumb = nil
        isThemeImageDeleted = true
    }
    
    func getSheetImage(thumb: Bool) -> UIImage? {
        if isSheetImageDeleted { return nil }
        if thumb {
            return newSelectedSheetImageThumb ?? uiImageThumbSheet
        }
        return newSelectedSheetImage ?? uiImageSheet
    }
    
    func getThemeImageData(thumb: Bool) -> Data? {
        getThemeImage(thumb: thumb)?.jpegData(compressionQuality: 0.4)
    }
    
    func getSheetImageData(thumb: Bool) -> Data? {
        return getSheetImage(thumb: thumb)?.jpegData(compressionQuality: 0.4)
    }
    
    func getTitleAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
        var attributes : [NSAttributedString.Key: Any] = [:]
        if let fontFamily = self.titleFontName {
            var font = UIFont(name: fontFamily, size: (CGFloat(self.titleTextSize) * scaleFactor))
            if self.isTitleBold {
                font = font?.setBoldFnc()
            }
            if self.isTitleItalic {
                font = font?.setItalicFnc()
            }
            attributes[.font] = font
        }
        
        let paragraph = NSMutableParagraphStyle()
        
        switch titleAlignmentNumber {
        case 0:
            paragraph.alignment = .left
            attributes[.paragraphStyle] = paragraph
        case 1:
            paragraph.alignment = .center
            attributes[.paragraphStyle] = paragraph
        case 2:
            paragraph.alignment = .right
            attributes[.paragraphStyle] = paragraph
        default:
            break
        }
        
        attributes[.strokeWidth] = Int(self.titleBorderSize)
        if let textColor = UIColor(hex: self.titleTextColorHex) {
            attributes[.foregroundColor] = textColor
        } else {
            attributes[.foregroundColor] = UIColor.black
        }
        
        if let borderColor = UIColor(hex: self.titleBorderColorHex) {
            attributes[.strokeColor] = borderColor
        }
        
        if self.isTitleUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = attributes[.foregroundColor]
        }
        
        return attributes
    }
    
    func getLyricsAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
        var attributes : [NSAttributedString.Key: Any] = [:]
        if let fontFamily = self.contentFontName {
            var font = UIFont(name: fontFamily, size: (CGFloat(self.contentTextSize) * scaleFactor))
            if self.isContentBold {
                font = font?.setBoldFnc()
            }
            if self.isContentItalic {
                font = font?.setItalicFnc()
            }
            attributes[.font] = font
        }
        
        let paragraph = NSMutableParagraphStyle()
        
        switch contentAlignmentNumber {
        case 0:
            paragraph.alignment = .left
            attributes[.paragraphStyle] = paragraph
        case 1:
            paragraph.alignment = .center
            attributes[.paragraphStyle] = paragraph
        case 2:
            paragraph.alignment = .right
            attributes[.paragraphStyle] = paragraph
        default:
            break
        }
        
        attributes[.strokeWidth] = Int(self.contentBorderSize)
        
        if let textColor = UIColor(hex: self.contentTextColorHex) {
            attributes[.foregroundColor] = textColor
        } else {
            attributes[.foregroundColor] = UIColor.black
        }
        
        if let borderColor = UIColor(hex: self.contentBorderColorHex) {
            attributes[.strokeColor] = borderColor
        }
        
        if self.isContentUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return attributes
    }
    
    func getPersistedThemes() -> [PickerRepresentable] {
        let themes: [Theme] = DataFetcher().getEntities(moc: moc)
        return themes.map { $0.pickerRepresentable }
    }
    
    mutating func deleteThemeImage() {
        newSelectedThemeImage = nil
        backgroundTransparancyNumber = 100
        isThemeImageDeleted = true
    }
    
    mutating func deleteSheetImage() {
        newSelectedSheetImage = nil
        isSheetImageDeleted = true
    }
    
    mutating func createThemeCodable() throws -> ThemeCodable? {
        let imagePath = try newSelectedThemeImage?.saveTemp()
        newSelectedThemeImageTempDirPath = imagePath
        
        switch editMode {
        case .theme:
            return ThemeCodable(
                userUID: theme.userUID,
                title: title,
                createdAt: theme.createdAt,
                updatedAt: nil,
                deleteDate: nil,
                rootDeleteDate: nil,
                allHaveTitle: allHaveTitle,
                backgroundColor: backgroundColor.toHex(),
                backgroundTransparancyNumber: backgroundTransparancyNumber,
                displayTime: displayTime,
                hasEmptySheet: hasEmptySheet,
                imagePath: self.imagePath,
                imagePathThumbnail: imagePathThumbnail,
                isEmptySheetFirst: isEmptySheetFirst,
                isHidden: isHidden,
                isContentBold: isContentBold,
                isContentItalic: isContentItalic,
                isContentUnderlined: isContentUnderlined,
                isTitleBold: isTitleBold,
                isTitleItalic: isTitleItalic,
                isTitleUnderlined: isTitleUnderlined,
                contentAlignmentNumber: contentAlignmentNumber,
                contentBorderColorHex: contentBorderColorHex,
                contentBorderSize: contentBorderSize,
                contentFontName: contentFontName,
                contentTextColorHex: contentTextColorHex,
                contentTextSize: contentTextSize,
                position: position,
                titleAlignmentNumber: titleAlignmentNumber,
                titleBackgroundColor: titleBackgroundColor,
                titleBorderColorHex: titleBorderColorHex,
                titleBorderSize: titleBorderSize,
                titleFontName: titleFontName,
                titleTextColorHex: titleTextColorHex,
                titleTextSize: titleTextSize,
                imagePathAWS: imagePathAWS,
                isUniversal: isUniversal,
                isDeletable: isDeletable,
                tempSelectedImage: nil,
                newSelectedThemeImageTempDirPath: imagePath,
                isThemeImageDeleted: isThemeImageDeleted
            )
        case .sheet:
            return nil
        }
    }
    
    mutating func createSheet() throws -> SheetMetaType? {
        let sheetImagePath = try newSelectedThemeImage?.saveTemp()
        newSelectedThemeImageTempDirPath = sheetImagePath

        switch editMode {
        case .sheet:
            switch sheetType {
            case .SheetTitleContent:
                return SheetTitleContentCodable(
                    id: sheet.id,
                    userUID: sheet.userUID,
                    title: sheet.title,
                    createdAt: sheet.createdAt,
                    updatedAt: sheet.updatedAt,
                    deleteDate: sheet.deleteDate,
                    rootDeleteDate: sheet.rootDeleteDate,
                    isEmptySheet: false,
                    position: 0,
                    time: 0,
                    hasTheme: nil,
                    content: self.sheetContent,
                    isBibleVers: false
                )
            case .SheetTitleImage:
                return SheetTitleImageCodable(
                    id: sheet.id,
                    userUID: sheet.userUID,
                    title: sheet.title,
                    createdAt: sheet.createdAt,
                    updatedAt: sheet.updatedAt,
                    deleteDate: sheet.deleteDate,
                    rootDeleteDate: sheet.rootDeleteDate,
                    isEmptySheet: false,
                    position: 0,
                    time: 0,
                    hasTheme: nil,
                    content: sheetContent,
                    hasTitle: !self.title.isBlanc,
                    imageBorderColor: nil,
                    imageBorderSize: 0,
                    imageContentMode: 0,
                    imageHasBorder: false,
                    imagePath: self.imagePath,
                    thumbnailPath: imagePathThumbnail,
                    imagePathAWS: sheetImagePathAWS
                )
            case .SheetPastors:
                return SheetPastorsCodable(
                    id: sheet.id,
                    userUID: sheet.userUID,
                    title: sheet.title,
                    createdAt: sheet.createdAt,
                    updatedAt: sheet.updatedAt,
                    deleteDate: sheet.deleteDate,
                    rootDeleteDate: sheet.rootDeleteDate,
                    isEmptySheet: false,
                    position: 0,
                    time: 0,
                    hasTheme: nil,
                    content: sheetContent,
                    imagePath: self.sheetImagePath,
                    thumbnailPath: self.sheetImagePathThumb,
                    imagePathAWS: sheetImagePathAWS
                )
            case .SheetSplit:
                return SheetTitleContentCodable(
                    id: sheet.id,
                    userUID: sheet.userUID,
                    title: sheet.title,
                    createdAt: sheet.createdAt,
                    updatedAt: sheet.updatedAt,
                    deleteDate: sheet.deleteDate,
                    rootDeleteDate: sheet.rootDeleteDate,
                    isEmptySheet: false,
                    position: 0,
                    time: 0,
                    hasTheme: nil,
                    content: self.sheetContent,
                    isBibleVers: false
                )
            case .SheetEmpty:
                return SheetEmptyCodable(
                    id: sheet.id,
                    userUID: sheet.userUID,
                    title: sheet.title,
                    createdAt: sheet.createdAt,
                    updatedAt: sheet.updatedAt,
                    deleteDate: sheet.deleteDate,
                    rootDeleteDate: sheet.rootDeleteDate,
                    isEmptySheet: false,
                    position: 0,
                    time: 0,
                    hasTheme: nil
                )
            case .SheetActivities:
                return SheetActivitiesCodable(
                    id: sheet.id,
                    userUID: sheet.userUID,
                    title: sheet.title,
                    createdAt: sheet.createdAt,
                    updatedAt: sheet.updatedAt,
                    deleteDate: sheet.deleteDate,
                    rootDeleteDate: sheet.rootDeleteDate,
                    hasGoogleActivities: [])
            }
        case .theme:
            return nil
        }
    }
    
}
