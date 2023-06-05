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

class SheetViewModel: ObservableObject, Identifiable, Equatable {
    
    enum SheetEditType {
        case theme
        case lyrics
        case bibleStudy
        case custom
        
        static func `for`(_ cluster: ClusterCodable, sheet: SheetMetaType) -> SheetEditType {
            if cluster.isTypeSong {
                return lyrics
            } else if sheet.isBibleVers {
                return .bibleStudy
            } else {
                return .custom
            }
        }
    }
    
    public var id: String {
        return sheetModel.sheet.id
    }

    let sheetEditType: SheetEditType
    @Published var themeModel: ThemeEditModel
    @Published var sheetModel: SheetEditModel
    
    @Published var title: String = ""
    
    init(cluster: ClusterCodable?, theme: ThemeCodable?, defaultTheme: ThemeCodable, sheet: SheetMetaType?, sheetType: SheetType, sheetEditType: SheetEditType) async throws {
        
        self.sheetEditType = sheetEditType
                
        let themeForModel: ThemeCodable?
        switch sheetEditType {
        case .lyrics:
            themeForModel = cluster?.theme
        case .bibleStudy:
            themeForModel = sheet?.theme ?? cluster?.theme
        case .custom:
            themeForModel = sheet?.theme
        case .theme:
            themeForModel = theme
        }
        
        if let themeForModel {
            themeModel = ThemeEditModel(
                theme: themeForModel,
                isNew: false
            )!
        } else {
            themeModel = ThemeEditModel(theme: defaultTheme, isNew: true)!
        }
        let fallBackDefaultSheet = await sheetType.makeDefault()!
        sheetModel = SheetEditModel(cluster: cluster, sheet: sheet ?? fallBackDefaultSheet, isNew: sheet == nil, sheetType: sheetType)!
        var title: String {
            let sheetTitle = sheetModel.title
            switch sheetEditType {
            case .theme:
                return themeModel.theme.title ?? ""
            case .lyrics: return themeModel.theme.allHaveTitle ? cluster?.title ?? "" : sheetModel.position == 0 ? cluster?.title ?? "" : ""
            case .bibleStudy, .custom: return sheetTitle
            }
        }
        self._title = Published(initialValue: title)
    }
    
    func createThemeCodable() throws -> ThemeCodable? {
        if [.theme, .custom].contains(sheetEditType) {
            themeModel.theme.title = title
        }
        return try themeModel.createThemeCodable()
    }
    
    func createSheetCodable() throws -> SheetMetaType? {
        let theme: ThemeCodable?
        switch sheetEditType {
        case .bibleStudy:
            if !sheetModel.sheet.isBibleVers {
                theme = try createThemeCodable()
            } else {
                theme = nil
            }
        case .custom:
            theme = try createThemeCodable()
            sheetModel.title = title
        default: theme = nil
        }
        return try sheetModel.createSheetCodable(with: theme)
    }
    
    static func == (lhs: SheetViewModel, rhs: SheetViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct ThemeEditModel: Identifiable {
    
    let id: String
    let isNew: Bool
    var theme: ThemeCodable
    
    private var uiImage: UIImage?
    private var uiImageThumb: UIImage?
    private var isImageDeleted: Bool = false

    var newSelectedImage: UIImage? { // binding
        didSet {
            newSelectedImageThumb = newSelectedImage?.resized(withPercentage: 0.4)
        }
    }
    private var newSelectedImageThumb: UIImage?
    
    init?(theme: ThemeCodable, isNew: Bool) {
        self.isNew = isNew
        self.theme = theme
        id = self.theme.id
        uiImage = self.theme.imagePath?.loadImage()
        uiImageThumb = self.theme.imagePathThumbnail?.loadImage()
    }
    
    mutating func setNewThemeImage(_ image: UIImage) {
        isImageDeleted = false
        newSelectedImage = image
        newSelectedImageThumb = image.resized(withPercentage: 0.4)
    }
    
    mutating func deleteThemeImage() {
        newSelectedImage = nil
        newSelectedImageThumb = nil
        theme.backgroundTransparancyNumber = 1
        isImageDeleted = true
    }
    
    func getPersistedThemes() async -> [PickerRepresentable] {
        let themes: [ThemeCodable] = await GetThemesUseCase().fetch()
        return themes.compactMap { $0.pickerRepresentable }
    }
    
    func getImage(thumb: Bool) -> UIImage? {
        if isImageDeleted { return nil }
        if thumb {
            return newSelectedImageThumb ?? uiImageThumb
        }
        return newSelectedImage ?? uiImage
    }

    mutating func styleAs(_ theme: ThemeCodable) {
        if let newBackgroundImage = self.theme.styleAsTheme(theme) {
            self.newSelectedImage = newBackgroundImage
        }
    }
    
    func createThemeCodable() throws -> ThemeCodable? {
        let saveImageUseCase = SaveImageUseCase()
        var newSelectedImageTempDirPath: String? = nil
        if let newSelectedImage {
            newSelectedImageTempDirPath = try saveImageUseCase.saveImageTemp(newSelectedImage)
        }
        
        var theme = self.theme
        theme.newSelectedThemeImageTempDirPath = newSelectedImageTempDirPath
        theme.isThemeImageDeleted = isImageDeleted
        
        return theme
    }
    
}

struct SheetEditModel: Identifiable {
    
    let id: String
    let isNew: Bool
    let cluster: ClusterCodable?
    let sheet: SheetMetaType
    let sheetType: SheetType
    
    var title: String = ""
    var content: String = ""
    var contentRight: String = ""
    var position: Int = 0
    
    var isImageDeleted: Bool = false
        
    var isBibleVers: Bool
    
    private var uiImage: UIImage?
    private var uiImageThumb: UIImage?
    private var newSelectedImageThumb: UIImage?
    
    var newSelectedImage: UIImage? { // binding
        didSet {
            newSelectedImageThumb = newSelectedImage?.resized(withPercentage: 0.4)
        }
    }
    
    init?(cluster: ClusterCodable?, sheet: SheetMetaType, isNew: Bool, sheetType: SheetType) {
        self.isNew = isNew
        self.cluster = cluster
        let sheet = sheet
        self.sheet = sheet
        self.sheetType = sheetType
        
        self.id = sheet.id
        self.position = sheet.position
        self.title = sheet.title ?? ""
        self.content = sheet.sheetContent ?? ""
        
        isBibleVers = sheet.isBibleVers
        
        uiImage = sheet.sheetImage
        uiImageThumb = sheet.sheetImageThumbnail
    }
    
    mutating func deleteSheetImage() {
        newSelectedImage = nil
        newSelectedImageThumb = nil
        isImageDeleted = true
    }

    mutating func setNewSheetImage(_ image: UIImage) {
        newSelectedImage = image
        newSelectedImageThumb = image.resized(withPercentage: 0.4)
    }
    
    func getImage(thumb: Bool) -> UIImage? {
        if isImageDeleted { return nil }
        if thumb {
            return newSelectedImageThumb ?? uiImageThumb
        }
        return newSelectedImage ?? uiImage
    }
    
    func getImageData(thumb: Bool) -> Data? {
        return getImage(thumb: thumb)?.jpegData(compressionQuality: 0.4)
    }
    
    func createSheetCodable(with theme: ThemeCodable?) throws -> SheetMetaType? {
        let saveImageUseCase = SaveImageUseCase()
        var newSelectedImageTempDirPath: String? = nil
        if let newSelectedImage {
            let sheetImagePath = try saveImageUseCase.saveImageTemp(newSelectedImage)
            newSelectedImageTempDirPath = sheetImagePath
        }
        
        switch sheetType {
        case .SheetTitleContent:
            guard var sheet = self.sheet as? SheetTitleContentCodable else { return nil }
            sheet.position = position
            sheet.hasTheme = theme
            sheet.title = title.isBlanc ? nil : title
            sheet.content = content
            sheet.isBibleVers = isBibleVers
            return sheet
        case .SheetTitleImage:
            guard var sheet = self.sheet as? SheetTitleImageCodable else { return nil }
            sheet.position = position
            sheet.content = content
            sheet.hasTheme = theme
            sheet.title = title.isBlanc ? nil : title
            if let title = sheet.title {
                sheet.hasTitle = !title.isBlanc
            } else {
                sheet.hasTitle = false
            }
            sheet.newSelectedSheetImageTempDirPath = newSelectedImageTempDirPath
            sheet.isSheetImageDeleted = isImageDeleted
            return sheet
        case .SheetPastors:
            guard var sheet = self.sheet as? SheetPastorsCodable else { return nil }
            sheet.title = title.isBlanc ? nil : title
            sheet.content = content
            sheet.position = position
            sheet.hasTheme = theme
            sheet.newSelectedSheetImageTempDirPath = newSelectedImageTempDirPath
            sheet.isSheetImageDeleted = isImageDeleted
            return sheet
        case .SheetSplit:
            guard var sheet = self.sheet as? SheetTitleContentCodable else { return nil }
            sheet.title = title.isBlanc ? nil : title
            sheet.position = position
            sheet.content = content
            sheet.hasTheme = theme
            sheet.isBibleVers = isBibleVers
            return sheet
        case .SheetEmpty:
            guard var sheet = self.sheet as? SheetEmptyCodable else { return nil }
            sheet.title = title.isBlanc ? nil : title
            sheet.position = position
            sheet.hasTheme = theme
            return sheet
        case .SheetActivities:
            return sheet
        }
    }
}
//
//struct SheetViewModel: Identifiable {
//
//    let id = UUID().uuidString
//
//    enum EditMode {
//        case theme(ThemeCodable?)
//        case sheet((cluster: ClusterCodable, sheet: SheetMetaType)?, sheetType: SheetType)
//
//        var isSheet: Bool {
//            switch self {
//            case .sheet: return true
//            case .theme: return false
//            }
//        }
//    }
//
//    let isNewEntity: Bool
//    let editMode: EditMode
//    let theme: ThemeCodable
//    let sheet: SheetMetaType
//    let cluster: ClusterCodable?
//    let sheetType: SheetType
//
//    var requestMethod: RequestMethod {
//        isNewEntity ? .post : .put
//    }
//
//    var allHaveTitle: Bool
//    var backgroundColor: Color
//    var backgroundTransparancyNumber: Double
//    var displayTime: Bool
//    var hasEmptySheet: Bool
//    var imagePath: String?
//    var imagePathThumbnail: String?
//    var isEmptySheetFirst: Bool
//    var isHidden: Bool
//    var isContentBold: Bool
//    var isContentItalic: Bool
//    var isContentUnderlined: Bool
//    var isTitleBold: Bool
//    var isTitleItalic: Bool
//    var isTitleUnderlined: Bool
//    var contentAlignmentNumber: Int16
//    var contentBorderColorHex: String?
//    var contentBorderSize: Float
//    var contentFontName: String?
//    var contentTextColorHex: String?
//    var contentTextSize: Float
//    var position: Int
//    var titleAlignmentNumber: Int16
//    var titleBackgroundColor: String?
//    var titleBorderColorHex: String?
//    var titleBorderSize: Float
//    var titleFontName: String?
//    var titleTextColorHex: String?
//    var titleTextSize: Float
//    var imagePathAWS: String?
//    var isUniversal: Bool
//    var isDeletable: Bool
//    var isBibleVers = false
//
//    // sheet properties
//    var title: String = ""
//    var sheetContent: String = ""
//    var sheetContentRight: String = ""
//    var sheetImagePath: String?
//    var sheetImagePathThumb: String?
//    var sheetImagePathAWS: String?
//
//    var uiImageTheme: UIImage?
//    var uiImageThumbTheme: UIImage?
//    var uiImageSheet: UIImage?
//    var uiImageThumbSheet: UIImage?
//
//    var newSelectedThemeImageTempDirPath: String? = nil
//    var newSelectedSheetImageTempDirPath: String? = nil
//
//    var newSelectedThemeImage: UIImage? { // binding
//        didSet {
//            newSelectedThemeImageThumb = newSelectedThemeImage?.resized(withPercentage: 0.4)
//        }
//    }
//    var newSelectedSheetImage: UIImage? { // binding
//        didSet {
//            newSelectedSheetImageThumb = newSelectedSheetImage?.resized(withPercentage: 0.4)
//        }
//    }
//    private var newSelectedThemeImageThumb: UIImage?
//    private var newSelectedSheetImageThumb: UIImage?
//
//    var isThemeImageDeleted: Bool = false
//    var isSheetImageDeleted: Bool = false
//
//    var imageBorderColor: String?
//    var imageBorderSize: Int16
//    var imageContentMode: Int16
//    var imageHasBorder: Bool
//
//    init?(editMode: EditMode, isUniversal: Bool, isCustomSheetType: Bool = false, isBibleVers: Bool) {
//        self.editMode = editMode
//        let theme: ThemeCodable
//        switch editMode {
//        case .theme(let persitedTheme):
//            self.isNewEntity = persitedTheme != nil
//            self.cluster = nil
//
//            if let extractedTheme = persitedTheme ?? ThemeCodable.makeDefault(), let sheet = SheetTitleContentCodable.makeDefault() {
//                theme = extractedTheme
//                self.sheet = sheet
//                self.sheetType = .SheetTitleContent
//                self.position = extractedTheme.position
//                self.isHidden = extractedTheme.isHidden
//            } else {
//                return nil
//            }
//        case .sheet(let persisted, let sheetType):
//            self.isNewEntity = persisted == nil
//            self.sheetType = sheetType
//
//            if let persisted {
//                let (cluster, sheet) = persisted
//                self.cluster = cluster
//                self.sheet = sheet
//                self.position = sheet.position
//                let clusterTheme = isCustomSheetType ? nil : cluster.theme
//                if let persistedTheme = sheet.theme ?? clusterTheme {
//                    theme = persistedTheme
//                    self.isHidden = theme.isHidden
//                } else if let defaultTheme = ThemeCodable.makeDefault() {
//                    theme = defaultTheme
//                    isHidden = true
//                } else {
//                    return nil
//                }
//            } else if let sheet = sheetType.makeDefault(), var defaultTheme = ThemeCodable.makeDefault() {
//                self.sheet = sheet
//                defaultTheme.isHidden = true
//                theme = defaultTheme
//                self.isHidden = true
//                self.position = sheet.position
//                self.cluster = nil
//            } else {
//                return nil
//            }
//        }
//        if isBibleVers {
//            self.title = sheet.title ?? ""
//            self.isBibleVers = true
//        } else if isCustomSheetType {
//            self.title = theme.allHaveTitle ? (sheet.title ?? "") : position == 0 ? (sheet.title ?? "")  : ""
//        } else if !isBibleVers {
//            if theme.allHaveTitle || position == 0 {
//                self.title = cluster?.title ?? theme.title ?? ""
//            }
//        }
//        self.isBibleVers = isBibleVers
//        self.allHaveTitle = theme.allHaveTitle
//        self.backgroundColor = theme.backgroundColor?.color ?? .white
//        self.backgroundTransparancyNumber = theme.backgroundTransparancyNumber
//        self.displayTime = theme.displayTime
//        self.hasEmptySheet = theme.hasEmptySheet
//        self.imagePath = theme.imagePath
//        self.imagePathThumbnail = theme.imagePathThumbnail
//        self.isEmptySheetFirst = theme.isEmptySheetFirst
//        self.isContentBold = theme.isContentBold
//        self.isContentItalic = theme.isContentItalic
//        self.isContentUnderlined = theme.isContentUnderlined
//        self.isTitleBold = theme.isTitleBold
//        self.isTitleItalic = theme.isTitleItalic
//        self.isTitleUnderlined = theme.isTitleUnderlined
//        self.contentAlignmentNumber = theme.contentAlignmentNumber
//        self.contentBorderColorHex = theme.contentBorderColorHex
//        self.contentBorderSize = theme.contentBorderSize
//        self.contentFontName = theme.contentFontName
//        self.contentTextColorHex = theme.contentTextColorHex
//        self.contentTextSize = theme.contentTextSize
//        self.titleAlignmentNumber = theme.titleAlignmentNumber
//        self.titleBackgroundColor = theme.titleBackgroundColor
//        self.titleBorderColorHex = theme.titleBorderColorHex
//        self.titleBorderSize = theme.titleBorderSize
//        self.titleFontName = theme.titleFontName
//        self.titleTextColorHex = theme.titleTextColorHex
//        self.titleTextSize = theme.titleTextSize
//        self.imagePathAWS = theme.imagePathAWS
//        self.isUniversal = isUniversal
//        self.isDeletable = !isUniversal
//
//        self.sheetContent = sheet.sheetContent ?? ""
//
//        self.sheetImagePath = sheet.sheetImagePath
//        self.sheetImagePathThumb = sheet.sheetImageThumbnailPath
//        self.uiImageTheme = imagePath?.loadImage()
//        self.uiImageThumbTheme = imagePathThumbnail?.loadImage()
//        self.uiImageSheet = sheetImagePath?.loadImage()
//        self.uiImageThumbSheet = sheetImagePathThumb?.loadImage()
//
//        if let sheet = sheet as? SheetTitleImageCodable {
//            imageBorderColor = sheet.imageBorderColor
//            imageBorderSize = sheet.imageBorderSize
//            imageContentMode = sheet.imageContentMode
//            imageHasBorder = sheet.imageHasBorder
//        } else {
//            imageBorderColor = nil
//            imageBorderSize = 0
//            imageContentMode = 0
//            imageHasBorder = false
//        }
//        self.theme = theme
//    }
//
//    mutating func styleAsTheme(_ theme: Theme) {
//        self.allHaveTitle = theme.allHaveTitle
//        self.backgroundColor = theme.backgroundColor?.color ?? .white
//        self.backgroundTransparancyNumber = theme.backgroundTransparancyNumber
//        self.displayTime = theme.displayTime
//        self.hasEmptySheet = theme.hasEmptySheet
//        self.isEmptySheetFirst = theme.isEmptySheetFirst
//        self.isHidden = theme.isHidden
//        self.isContentBold = theme.isContentBold
//        self.isContentItalic = theme.isContentItalic
//        self.isContentUnderlined = theme.isContentUnderlined
//        self.isTitleBold = theme.isTitleBold
//        self.isTitleItalic = theme.isTitleItalic
//        self.isTitleUnderlined = theme.isTitleUnderlined
//        self.contentAlignmentNumber = theme.contentAlignmentNumber
//        self.contentBorderColorHex = theme.contentBorderColorHex
//        self.contentBorderSize = theme.contentBorderSize
//        self.contentFontName = theme.contentFontName
//        self.contentTextColorHex = theme.contentTextColorHex
//        self.contentTextSize = theme.contentTextSize
//        self.titleAlignmentNumber = theme.titleAlignmentNumber
//        self.titleBackgroundColor = theme.titleBackgroundColor
//        self.titleBorderColorHex = theme.titleBorderColorHex
//        self.titleBorderSize = theme.titleBorderSize
//        self.titleFontName = theme.titleFontName
//        self.titleTextColorHex = theme.titleTextColorHex
//        self.titleTextSize = theme.titleTextSize
//
//        if let themeBackgroundImage = theme.imagePath?.loadImage() {
//            self.newSelectedThemeImage = themeBackgroundImage
//        }
//    }
//
//    mutating func styleAsTheme(_ theme: ThemeCodable) {
//        self.allHaveTitle = theme.allHaveTitle
//        self.backgroundColor = theme.backgroundColor?.color ?? .white
//        self.backgroundTransparancyNumber = theme.backgroundTransparancyNumber
//        self.displayTime = theme.displayTime
//        self.hasEmptySheet = theme.hasEmptySheet
//        self.isEmptySheetFirst = theme.isEmptySheetFirst
//        self.isHidden = theme.isHidden
//        self.isContentBold = theme.isContentBold
//        self.isContentItalic = theme.isContentItalic
//        self.isContentUnderlined = theme.isContentUnderlined
//        self.isTitleBold = theme.isTitleBold
//        self.isTitleItalic = theme.isTitleItalic
//        self.isTitleUnderlined = theme.isTitleUnderlined
//        self.contentAlignmentNumber = theme.contentAlignmentNumber
//        self.contentBorderColorHex = theme.contentBorderColorHex
//        self.contentBorderSize = theme.contentBorderSize
//        self.contentFontName = theme.contentFontName
//        self.contentTextColorHex = theme.contentTextColorHex
//        self.contentTextSize = theme.contentTextSize
//        self.titleAlignmentNumber = theme.titleAlignmentNumber
//        self.titleBackgroundColor = theme.titleBackgroundColor
//        self.titleBorderColorHex = theme.titleBorderColorHex
//        self.titleBorderSize = theme.titleBorderSize
//        self.titleFontName = theme.titleFontName
//        self.titleTextColorHex = theme.titleTextColorHex
//        self.titleTextSize = theme.titleTextSize
//
//        if let backgroundImage = theme.backgroundImage {
//            self.newSelectedThemeImage = backgroundImage
//        }
//    }
//
//    mutating func setNewThemeImage(_ image: UIImage) {
//        isThemeImageDeleted = false
//        newSelectedThemeImage = image
//        newSelectedThemeImageThumb = image.resized(withPercentage: 0.4)
//    }
//
//    mutating func deleteNewThemeImage() {
//        newSelectedThemeImage = nil
//        newSelectedThemeImageThumb = nil
//        isThemeImageDeleted = true
//    }
//
//    func getThemeImage(thumb: Bool) -> UIImage? {
//        if isThemeImageDeleted { return nil }
//        if thumb {
//            return newSelectedThemeImageThumb ?? uiImageThumbTheme
//        }
//        return newSelectedThemeImage ?? uiImageTheme
//    }
//
//    mutating func setNewSheetImage(_ image: UIImage) {
//        newSelectedSheetImage = image
//        newSelectedSheetImageThumb = image.resized(withPercentage: 0.4)
//    }
//
//    mutating func deleteNewSheetImage() {
//        newSelectedSheetImage = nil
//        newSelectedSheetImageThumb = nil
//        isThemeImageDeleted = true
//    }
//
//    func getSheetImage(thumb: Bool) -> UIImage? {
//        if isSheetImageDeleted { return nil }
//        if thumb {
//            return newSelectedSheetImageThumb ?? uiImageThumbSheet
//        }
//        return newSelectedSheetImage ?? uiImageSheet
//    }
//
//    func getThemeImageData(thumb: Bool) -> Data? {
//        getThemeImage(thumb: thumb)?.jpegData(compressionQuality: 0.4)
//    }
//
//    func getSheetImageData(thumb: Bool) -> Data? {
//        return getSheetImage(thumb: thumb)?.jpegData(compressionQuality: 0.4)
//    }
//
//    func getTitleAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
//        var attributes : [NSAttributedString.Key: Any] = [:]
//        if let fontFamily = self.titleFontName {
//            var font = UIFont(name: fontFamily, size: (CGFloat(self.titleTextSize) * scaleFactor))
//            if self.isTitleBold {
//                font = font?.setBoldFnc()
//            }
//            if self.isTitleItalic {
//                font = font?.setItalicFnc()
//            }
//            attributes[.font] = font
//        }
//
//        let paragraph = NSMutableParagraphStyle()
//
//        switch titleAlignmentNumber {
//        case 0:
//            paragraph.alignment = .left
//            attributes[.paragraphStyle] = paragraph
//        case 1:
//            paragraph.alignment = .center
//            attributes[.paragraphStyle] = paragraph
//        case 2:
//            paragraph.alignment = .right
//            attributes[.paragraphStyle] = paragraph
//        default:
//            break
//        }
//
//        attributes[.strokeWidth] = Int(self.titleBorderSize)
//        if let textColor = UIColor(hex: self.titleTextColorHex) {
//            attributes[.foregroundColor] = textColor
//        } else {
//            attributes[.foregroundColor] = UIColor.black
//        }
//
//        if let borderColor = UIColor(hex: self.titleBorderColorHex) {
//            attributes[.strokeColor] = borderColor
//        }
//
//        if self.isTitleUnderlined {
//            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
//            attributes[.underlineColor] = attributes[.foregroundColor]
//        }
//
//        return attributes
//    }
//
//    func getLyricsAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
//        var attributes : [NSAttributedString.Key: Any] = [:]
//        if let fontFamily = self.contentFontName {
//            var font = UIFont(name: fontFamily, size: (CGFloat(self.contentTextSize) * scaleFactor))
//            if self.isContentBold {
//                font = font?.setBoldFnc()
//            }
//            if self.isContentItalic {
//                font = font?.setItalicFnc()
//            }
//            attributes[.font] = font
//        }
//
//        let paragraph = NSMutableParagraphStyle()
//
//        switch contentAlignmentNumber {
//        case 0:
//            paragraph.alignment = .left
//            attributes[.paragraphStyle] = paragraph
//        case 1:
//            paragraph.alignment = .center
//            attributes[.paragraphStyle] = paragraph
//        case 2:
//            paragraph.alignment = .right
//            attributes[.paragraphStyle] = paragraph
//        default:
//            break
//        }
//
//        attributes[.strokeWidth] = Int(self.contentBorderSize)
//
//        if let textColor = UIColor(hex: self.contentTextColorHex) {
//            attributes[.foregroundColor] = textColor
//        } else {
//            attributes[.foregroundColor] = UIColor.black
//        }
//
//        if let borderColor = UIColor(hex: self.contentBorderColorHex) {
//            attributes[.strokeColor] = borderColor
//        }
//
//        if self.isContentUnderlined {
//            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
//        }
//        return attributes
//    }
//
//    func getPersistedThemes() -> [PickerRepresentable] {
//        let themes: [Theme] = DataFetcher().getEntities(moc: moc)
//        return themes.compactMap { ThemeCodable(managedObject: $0, context: moc)?.pickerRepresentable }
//    }
//
//    mutating func deleteThemeImage() {
//        newSelectedThemeImage = nil
//        backgroundTransparancyNumber = 1
//        isThemeImageDeleted = true
//    }
//
//    mutating func deleteSheetImage() {
//        newSelectedSheetImage = nil
//        isSheetImageDeleted = true
//    }
//
//    mutating func createThemeCodable() throws -> ThemeCodable? {
//        if let newSelectedThemeImage {
//            let imagePath = try newSelectedThemeImage.saveTemp()
//            newSelectedThemeImageTempDirPath = imagePath
//        }
//
//        return ThemeCodable(
//            id: theme.id,
//            userUID: theme.userUID,
//            title: title,
//            createdAt: theme.createdAt,
//            updatedAt: nil,
//            deleteDate: nil,
//            rootDeleteDate: nil,
//            allHaveTitle: allHaveTitle,
//            backgroundColor: backgroundColor.toHex(),
//            backgroundTransparancyNumber: backgroundTransparancyNumber,
//            displayTime: displayTime,
//            hasEmptySheet: hasEmptySheet,
//            imagePath: self.imagePath,
//            imagePathThumbnail: imagePathThumbnail,
//            isEmptySheetFirst: isEmptySheetFirst,
//            isHidden: isHidden,
//            isContentBold: isContentBold,
//            isContentItalic: isContentItalic,
//            isContentUnderlined: isContentUnderlined,
//            isTitleBold: isTitleBold,
//            isTitleItalic: isTitleItalic,
//            isTitleUnderlined: isTitleUnderlined,
//            contentAlignmentNumber: contentAlignmentNumber,
//            contentBorderColorHex: contentBorderColorHex,
//            contentBorderSize: contentBorderSize,
//            contentFontName: contentFontName,
//            contentTextColorHex: contentTextColorHex,
//            contentTextSize: contentTextSize,
//            position: editMode.isSheet ? theme.position : position,
//            titleAlignmentNumber: titleAlignmentNumber,
//            titleBackgroundColor: titleBackgroundColor,
//            titleBorderColorHex: titleBorderColorHex,
//            titleBorderSize: titleBorderSize,
//            titleFontName: titleFontName,
//            titleTextColorHex: titleTextColorHex,
//            titleTextSize: titleTextSize,
//            imagePathAWS: imagePathAWS,
//            isUniversal: isUniversal,
//            isDeletable: isDeletable,
//            tempSelectedImage: nil,
//            newSelectedThemeImageTempDirPath: newSelectedThemeImageTempDirPath,
//            isThemeImageDeleted: isThemeImageDeleted
//        )
//    }
//
//    mutating func createSheetCodable() throws -> SheetMetaType? {
//        if let newSelectedSheetImage {
//            let sheetImagePath = try newSelectedSheetImage.saveTemp()
//            newSelectedSheetImageTempDirPath = sheetImagePath
//        }
//        switch editMode {
//        case .sheet:
//            switch sheetType {
//            case .SheetTitleContent:
//                return SheetTitleContentCodable(
//                    id: sheet.id,
//                    userUID: sheet.userUID,
//                    title: sheet.title,
//                    createdAt: sheet.createdAt,
//                    updatedAt: sheet.updatedAt,
//                    deleteDate: sheet.deleteDate,
//                    rootDeleteDate: sheet.rootDeleteDate,
//                    isEmptySheet: false,
//                    position: position,
//                    time: 0,
//                    hasTheme: isBibleVers ? nil : try createThemeCodable(),
//                    content: self.sheetContent,
//                    isBibleVers: isBibleVers
//                )
//            case .SheetTitleImage:
//                return SheetTitleImageCodable(
//                    id: sheet.id,
//                    userUID: sheet.userUID,
//                    title: sheet.title,
//                    createdAt: sheet.createdAt,
//                    updatedAt: sheet.updatedAt,
//                    deleteDate: sheet.deleteDate,
//                    rootDeleteDate: sheet.rootDeleteDate,
//                    isEmptySheet: false,
//                    position: position,
//                    time: 0,
//                    hasTheme: try createThemeCodable(),
//                    content: sheetContent,
//                    hasTitle: !self.title.isBlanc,
//                    imageBorderColor: nil,
//                    imageBorderSize: 0,
//                    imageContentMode: 0,
//                    imageHasBorder: false,
//                    imagePath: self.imagePath,
//                    thumbnailPath: imagePathThumbnail,
//                    imagePathAWS: sheetImagePathAWS,
//                    newSelectedSheetImageTempDirPath: newSelectedSheetImageTempDirPath,
//                    isSheetImageDeleted: isSheetImageDeleted
//                )
//            case .SheetPastors:
//                return SheetPastorsCodable(
//                    id: sheet.id,
//                    userUID: sheet.userUID,
//                    title: sheet.title,
//                    createdAt: sheet.createdAt,
//                    updatedAt: sheet.updatedAt,
//                    deleteDate: sheet.deleteDate,
//                    rootDeleteDate: sheet.rootDeleteDate,
//                    isEmptySheet: false,
//                    position: position,
//                    time: 0,
//                    hasTheme: try createThemeCodable(),
//                    content: sheetContent,
//                    imagePath: self.sheetImagePath,
//                    thumbnailPath: self.sheetImagePathThumb,
//                    imagePathAWS: sheetImagePathAWS,
//                    newSelectedSheetImageTempDirPath: newSelectedSheetImageTempDirPath,
//                    isSheetImageDeleted: isSheetImageDeleted
//                )
//            case .SheetSplit:
//                return SheetTitleContentCodable(
//                    id: sheet.id,
//                    userUID: sheet.userUID,
//                    title: sheet.title,
//                    createdAt: sheet.createdAt,
//                    updatedAt: sheet.updatedAt,
//                    deleteDate: sheet.deleteDate,
//                    rootDeleteDate: sheet.rootDeleteDate,
//                    isEmptySheet: false,
//                    position: position,
//                    time: 0,
//                    hasTheme: try createThemeCodable(),
//                    content: self.sheetContent,
//                    isBibleVers: false
//                )
//            case .SheetEmpty:
//                return SheetEmptyCodable(
//                    id: sheet.id,
//                    userUID: sheet.userUID,
//                    title: sheet.title,
//                    createdAt: sheet.createdAt,
//                    updatedAt: sheet.updatedAt,
//                    deleteDate: sheet.deleteDate,
//                    rootDeleteDate: sheet.rootDeleteDate,
//                    isEmptySheet: isBibleVers,
//                    position: position,
//                    time: 0,
//                    hasTheme: isBibleVers ? nil : try createThemeCodable()
//                )
//            case .SheetActivities:
//                return SheetActivitiesCodable(
//                    id: sheet.id,
//                    userUID: sheet.userUID,
//                    title: sheet.title,
//                    createdAt: sheet.createdAt,
//                    updatedAt: sheet.updatedAt,
//                    deleteDate: sheet.deleteDate,
//                    rootDeleteDate: sheet.rootDeleteDate,
//                    hasGoogleActivities: [])
//            }
//        case .theme:
//            return nil
//        }
//    }
//
//}
