//
//  ThemeDraft.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

class ThemeDraft {
        
    enum ImageSelectionAction {
        case image(UIImage)
        case delete
        case none
        
        var needsDeletion: Bool {
            switch self {
            case .delete, .image: return true
            case .none: return false
            }
        }
        
        var image: UIImage? {
            switch self {
            case .image(let image): return image
            case .none, .delete: return nil
            }
        }
    }
    
    private(set) var id: String = "CHURCHBEAM" + UUID().uuidString
    private(set) var userUID: String = ""
    var title: String? = nil
    private(set) var createdAt: Date = Date.localDate()
    private(set) var updatedAt: Date? = nil
    private(set) var deleteDate: Date? = nil
    private(set) var rootDeleteDate: Date? = nil
    
    private(set) var allHaveTitle: Bool = false
    private(set) var backgroundColor: String? = nil
    var backgroundTransparancyNumber: Double = 0
    private(set) var displayTime: Bool = false
    private(set) var hasEmptySheet: Bool = false
    private(set) var imagePath: String? = nil
    private(set) var imagePathThumbnail: String? = nil
    private(set) var isEmptySheetFirst: Bool = false
    private(set) var isHidden: Bool = false
    private(set) var isContentBold: Bool = false
    private(set) var isContentItalic: Bool = false
    private(set) var isContentUnderlined: Bool = false
    private(set) var isTitleBold: Bool = false
    private(set) var isTitleItalic: Bool = false
    private(set) var isTitleUnderlined: Bool = false
    private(set) var contentAlignmentNumber: Int16 = 0
    private(set) var contentBorderColorHex: String? = nil
    private(set) var contentBorderSize: Float = 0
    private(set) var contentFontName: String? = "Avenir"
    private(set) var contentTextColorHex: String? = "000000"
    private(set) var contentTextSize: Float = 9
    private(set) var position: Int16 = 0
    private(set) var titleAlignmentNumber: Int16 = 0
    private(set) var titleBackgroundColor: String? = nil
    private(set) var titleBorderColorHex: String? = nil
    private(set) var titleBorderSize: Float = 0
    private(set) var titleFontName: String? = "Avenir"
    private(set) var titleTextColorHex: String? = "000000"
    private(set) var titleTextSize: Float = 11
    private(set) var imagePathAWS: String? = nil
    private(set) var isUniversal: Bool = false
    private(set) var isDeletable: Bool = true
    
    private(set) var backgroundImage: UIImage? {
        get {
            try? LoadImageUseCase(name: imagePath)?.loadImage()
        }
        set {
        }
    }
    private(set) var thumbnail: UIImage? {
        get {
            try? LoadImageUseCase(name: imagePathThumbnail)?.loadImage()
        }
        set {
        }
    }
    
    private(set) var imageSelectionAction: ImageSelectionAction = .none
    var tempSavedImageName: String?
    var backgroundTransparancy: Double {
        get { return backgroundTransparancyNumber * 100 }
        set { backgroundTransparancyNumber = newValue / 100 }
    }
    
    var textColorTitle: UIColor? {
        get {
            guard let hex = titleTextColorHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                titleTextColorHex = newColor.hexCode
            }
        }
    }
    
    var backgroundColorTitle: UIColor? {
        get {
            guard let hex = titleBackgroundColor else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                titleBackgroundColor = newColor.hexCode
            }
        }
    }
    
    var sheetBackgroundColor: UIColor? {
        get {
            guard let hex = backgroundColor else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                backgroundColor = newColor.hexCode
            }
        }
    }
    
    var borderColorTitle: UIColor? {
        get {
            guard let hex = titleBorderColorHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                titleBorderColorHex = newColor.hexCode
            }
        }
    }
    
    var textColorLyrics: UIColor? {
        get {
            guard let hex = contentTextColorHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                contentTextColorHex = newColor.hexCode
            }
        }
    }
    
    var borderColorLyrics: UIColor? {
        get {
            guard let hex = contentBorderColorHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                contentBorderColorHex = newColor.hexCode
            }
        }
    }
    
    init(theme: ThemeCodable? = nil) {
        guard let theme = theme else {
            return
        }
        updateFrom(theme)
    }
    
    func updateFrom(_ theme: ThemeCodable?) {
        guard let theme = theme else {
            return
        }
        id = theme.id
        userUID = theme.userUID
        title = theme.title
        createdAt = theme.createdAt
        updatedAt = theme.updatedAt
        deleteDate = theme.deleteDate
        rootDeleteDate = theme.rootDeleteDate
        allHaveTitle = theme.allHaveTitle
        
        backgroundColor = theme.backgroundColor
        backgroundTransparancyNumber = theme.backgroundTransparancyNumber
        displayTime = theme.displayTime
        hasEmptySheet = theme.hasEmptySheet
        imagePath = theme.imagePath
        imagePathThumbnail = theme.imagePathThumbnail
        isEmptySheetFirst = theme.isEmptySheetFirst
        isHidden = theme.isHidden
        isContentBold = theme.isContentBold
        isContentItalic = theme.isContentItalic
        isContentUnderlined = theme.isContentUnderlined
        isTitleBold = theme.isTitleBold
        isTitleItalic = theme.isTitleItalic
        isTitleUnderlined = theme.isTitleUnderlined
        contentAlignmentNumber = theme.contentAlignmentNumber
        contentBorderColorHex = theme.contentBorderColorHex
        contentBorderSize = theme.contentBorderSize
        contentFontName = theme.contentFontName
        contentTextColorHex = theme.contentTextColorHex
        contentTextSize = theme.contentTextSize
        position = Int16(theme.position)
        titleAlignmentNumber = theme.titleAlignmentNumber
        titleBackgroundColor = theme.titleBackgroundColor
        titleBorderColorHex = theme.titleBorderColorHex
        titleBorderSize = theme.titleBorderSize
        titleFontName = theme.titleFontName
        titleTextColorHex = theme.titleTextColorHex
        titleTextSize = theme.titleTextSize
        imagePathAWS = theme.imagePathAWS
        isUniversal = theme.isUniversal
        isDeletable = theme.isDeletable
    }
    
    func makeCodable() throws -> ThemeCodable {
        return ThemeCodable(
            id: id,
            userUID: userUID,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleteDate: deleteDate,
            rootDeleteDate: rootDeleteDate,
            allHaveTitle: allHaveTitle,
            backgroundColor: backgroundColor,
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
            position: position.intValue,
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
            tempSelectedImage: imageSelectionAction.image,
            newSelectedThemeImageTempDirPath: nil,
            isThemeImageDeleted: false
        )
    }
    
    var uploadObjecs: [UploadObject] {
        let themesPaths = [self].compactMap({ $0.tempSavedImageName })
        return themesPaths.compactMap({ UploadObject(fileName: $0) })
    }
    
    func setImageSelectionAction(_ action: ImageSelectionAction, imageName: String?) {
        if let tempSavedImageName = tempSavedImageName {
        }
        tempSavedImageName = imageName
        self.imageSelectionAction = action
    }
    
    func hasAnyImage() -> Bool {
        switch imageSelectionAction {
        case .none: return imagePath != nil
        case .delete: return false
        case .image: return true
        }
    }
    
    func setDownloadValues(_ downloadObjects: [DownloadObject]) {
        for download in downloadObjects.compactMap({ $0 as DownloadObject }) {
            if imagePathAWS == download.remoteURL.absoluteString {
                do {
                    try setBackgroundImage(image: download.image, imageName: download.filename)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func setUploadValues(_ uploadObjects: [UploadObject]) {
        for upload in uploadObjects.compactMap({ $0 as UploadObject }) {
            if tempSavedImageName == upload.fileName {
                imagePathAWS = upload.fileName
            }
        }
    }
    
    func setBackgroundImage(image: UIImage?, imageName: String?) {
    }
    
    func update(_ cell: NewOrEditIphoneController.Cell) throws {
        switch cell {
        case .title(let value): title = value

        case .asTheme(let value): updateFrom(value.first)
        case .hasEmptySheet(let value): hasEmptySheet = value
        case .hasEmptySheetBeginning(let value): isEmptySheetFirst = value
        case .allHaveTitle(let value): allHaveTitle = value
        case .backgroundColor(let value): backgroundColor = value?.hexCode
        case .backgroundImage(let image, let imageName):
            if let image = image {
                setImageSelectionAction(.image(image), imageName: imageName)
            } else if imageSelectionAction.image != nil {
                setImageSelectionAction(.none, imageName: nil)
            } else {
                setImageSelectionAction(.delete, imageName: nil)
            }
        case .backgroundTransparancy(let value): backgroundTransparancy = value
        case .displayTime(let value): displayTime = value
                
        case .titleFontFamily(let value): titleFontName = value
        case .titleFontSize(let value): titleTextSize = value
        case .titleBackgroundColor(let value): titleBackgroundColor = value?.hexCode
        case .titleAlignment(let value): titleAlignmentNumber = Int16(value)
        case .titleBorderSize(let value): titleBorderSize = value
        case .titleTextColor(let value): titleTextColorHex = value?.hexCode
        case .titleBorderColor(let value): titleBorderColorHex = value?.hexCode
        case .titleBold(let value): isTitleBold = value
        case .titleItalic(let value): isTitleItalic = value
        case .titleUnderlined(let value): isTitleUnderlined = value

        case .lyricsFontFamily(let value): contentFontName = value
        case .lyricsFontSize(let value): contentTextSize = value
        case .lyricsAlignment(let value): contentAlignmentNumber = Int16(value)
        case .lyricsBorderSize(let value): contentBorderSize = value
        case .lyricsTextColor(let value): contentTextColorHex = value?.hexCode
        case .lyricsBorderColor(let value): contentBorderColorHex = value?.hexCode
        case .lyricsBold(let value): isContentBold = value
        case .lyricsItalic(let value): isContentItalic = value
        case .lyricsUnderlined(let value): isContentUnderlined = value

        default: break
        }
        
//        switch property {
//        case .id(let value): id = value
//        case .userUID(let value): userUID = value
//        case .title(let value): title = value
//        case .createdAt(let value): createdAt = value
//        case .updatedAt(let value): updatedAt = value
//        case .deleteDate(let value): deleteDate = value
//        case .rootDeleteDate(let value): rootDeleteDate = value
//        case .allHaveTitle(let value): allHaveTitle = value
//        case .backgroundColor(let value): backgroundColor = value
//        case .backgroundTransparancyNumber(let value): backgroundTransparancyNumber = value
//        case .displayTime(let value): displayTime = value
//        case .hasEmptySheet(let value): hasEmptySheet = value
//        case .imagePath(let value): imagePath = value
//        case .imagePathThumbnail(let value): imagePathThumbnail = value
//        case .isEmptySheetFirst(let value): isEmptySheetFirst = value
//        case .isHidden(let value): isHidden = value
//        case .isContentBold(let value): isContentBold = value
//        case .isContentItalic(let value): isContentItalic = value
//        case .isContentUnderlined(let value): isContentUnderlined = value
//        case .isTitleBold(let value): isTitleBold = value
//        case .isTitleItalic(let value): isTitleItalic = value
//        case .isTitleUnderlined(let value): isTitleUnderlined = value
//        case .contentAlignmentNumber(let value): contentAlignmentNumber = value
//        case .contentBorderColorHex(let value): contentBorderColorHex = value
//        case .contentBorderSize(let value): contentBorderSize = value
//        case .contentFontName(let value): contentFontName = value
//        case .contentTextColorHex(let value): contentTextColorHex = value
//        case .contentTextSize(let value): contentTextSize = value
//        case .position(let value): position = value
//        case .titleAlignmentNumber(let value): titleAlignmentNumber = value
//        case .titleBackgroundColor(let value): titleBackgroundColor = value
//        case .titleBorderColorHex(let value): titleBorderColorHex = value
//        case .titleBorderSize(let value): titleBorderSize = value
//        case .titleFontName(let value): titleFontName = value
//        case .titleTextColorHex(let value): titleTextColorHex = value
//        case .titleTextSize(let value): titleTextSize = value
//        case .imagePathAWS(let value): imagePathAWS = value
//        case .isUniversal(let value): isUniversal = value
//        case .isDeletable(let value): isDeletable = value
//        case .updateImage(let value): imageSelectionAction = .image(value)
//        case .deleteImage: imageSelectionAction = .delete
//        }
    }
}
