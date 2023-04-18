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
        case newTheme
        case persistedTheme(ThemeCodable)
        case persistedSheet(SheetMetaType, sheetType: SheetType)
        case newSheet(SheetMetaType, sheetType: SheetType)
        
        var isEditingSheet: Bool {
            switch self {
            case .newSheet, .persistedSheet: return true
            case .newTheme, .persistedTheme: return false
            }
        }
    }
    
    let editMode: EditMode
    let sheet: SheetMetaType
    let sheetType: SheetType
    let theme: ThemeCodable
    
    var requestMethod: RequestMethod {
        switch editMode {
        case .newTheme, .newSheet: return .post
        case .persistedTheme, .persistedSheet: return .put
        }
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
    
    var newSelectedThemeImageTempDirPath: String? = nil
    var newSelectedThemeImage: UIImage?
    var newSelectedThemeImageThumb: UIImage? {
        newSelectedThemeImage?.resized(withPercentage: 0.4)
    }
    var newSelectedThemeImageData: Data? {
        newSelectedThemeImage?.jpegData(compressionQuality: 1.0)
    }
    var newSelectedThemeImageThumbData: Data? {
        newSelectedThemeImage?.resized(withPercentage: 0.4)?.jpegData(compressionQuality: 0.4)
    }
    var newSelectedSheetImageTempDirPath: String? = nil
    var newSelectedSheetImage: UIImage?
    var newSelectedSheetThumb: UIImage? {
        newSelectedSheetImage?.resized(withPercentage: 0.4)
    }
    var newSelectedtSheetImageData: Data? {
        newSelectedSheetImage?.jpegData(compressionQuality: 1.0)
    }
    var newSelectedSheetImageThumbData: Data? {
        newSelectedSheetImage?.resized(withPercentage: 0.4)?.jpegData(compressionQuality: 0.4)
    }
    
    var themeImage: UIImage? {
        if isThemeImageDeleted {
            return nil
        }
        return imagePath?.loadImage()
    }
    var themeImageThumb: UIImage? {
        if isThemeImageDeleted {
            return nil
        }
        return imagePathThumbnail?.loadImage()
    }
    var themeImageData: Data? {
        if isThemeImageDeleted {
            return nil
        }
        return imagePath?.loadImage()?.jpegData(compressionQuality: 1)
    }
    var themeImageThumbData: Data? {
        if isThemeImageDeleted {
            return nil
        }
        return imagePathThumbnail?.loadImage()?.jpegData(compressionQuality: 0.4)
    }
    var sheetImageData: Data? {
        if isSheetImageDeleted {
            return nil
        }
        return sheetImagePath?.loadImage()?.jpegData(compressionQuality: 1)
    }
    var sheetImageThumbData: Data? {
        if isSheetImageDeleted {
            return nil
        }
        return sheetImagePathThumb?.loadImage()?.jpegData(compressionQuality: 0.4)
    }
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
        case .newTheme:
            if let defaultTheme = ThemeCodable.makeDefault() {
                theme = defaultTheme
            } else {
                return nil
            }
            if let sheet = SheetTitleContentCodable.makeDefault() {
                self.sheet = sheet
                self.sheetType = .SheetTitleContent
            } else {
                return nil
            }
        case .persistedTheme(let persitedTheme):
            theme = persitedTheme
            if let sheet = SheetTitleContentCodable.makeDefault() {
                self.sheet = sheet
                self.sheetType = .SheetTitleContent
            } else {
                return nil
            }
        case .persistedSheet(let persitedSheet, let sheetType):
            sheet = persitedSheet
            self.sheetType = sheetType
            if let defaultTheme = persitedSheet.theme ?? ThemeCodable.makeDefault(isHidden: true) {
                theme = defaultTheme
            } else {
                return nil
            }
        case .newSheet(let newSheet, let sheetType):
            sheet = newSheet
            self.sheetType = sheetType
            if let defaultTheme = ThemeCodable.makeDefault(isHidden: true) {
                theme = defaultTheme
            } else {
                return nil
            }
        }
        self.theme = theme
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
        let sheetImagePath = try newSelectedSheetImage?.saveTemp()
        newSelectedSheetImageTempDirPath = sheetImagePath
        let imagePathThumb = try newSelectedThemeImage?.resized(withPercentage: 0.4)?.saveTemp()
        newSelectedThemeImageTempDirPath = imagePathThumb
        let sheetImagePathThumb = try newSelectedSheetImage?.resized(withPercentage: 0.4)?.saveTemp()
        newSelectedSheetImageTempDirPath = sheetImagePathThumb
        
        switch editMode {
        case .newTheme, .persistedTheme:
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
                imagePath: imagePath,
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
                newSelectedThemeImageTempDirPath: newSelectedThemeImageTempDirPath,
                newSelectedSheetImageTempDirPath: newSelectedSheetImageTempDirPath,
                newSelectedThemeImageThumbTempDirPath: newSelectedThemeImageTempDirPath,
                newSelectedSheetImageThumbTempDirPath: newSelectedSheetImageTempDirPath,
                isThemeImageDeleted: isThemeImageDeleted,
                isSheetImageDeleted: isSheetImageDeleted
            )
        case .newSheet, .persistedSheet:
            return nil
        }
    }
}
