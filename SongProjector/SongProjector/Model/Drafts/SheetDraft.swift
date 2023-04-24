//
//  SheetDraft.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetDraft {
    
    enum CodableOutput {
        case sheetTitleContent(SheetTitleContentCodable)
        case sheetTitleImage(SheetTitleImageCodable)
        case sheetEmpty(SheetEmptyCodable)
        case sheetSplit(SheetSplitCodable)
        case sheetPastors(SheetPastorsCodable)
        case none
        
        var themeCodable: ThemeCodable? {
            switch self {
            case .sheetTitleContent(let sheet): return sheet.hasTheme
            case .sheetTitleImage(let sheet): return sheet.hasTheme
            case .sheetEmpty(let sheet): return sheet.hasTheme
            case .sheetSplit(let sheet): return sheet.hasTheme
            case .sheetPastors(let sheet): return sheet.hasTheme
            case .none: return nil
            }
        }
    }
    
    enum UpdateProperties {
        case id(String)
        case userUID(String)
        case title(String?)
        case createdAt(Date)
        case updatedAt(Date?)
        case deleteDate(Date?)
        case isTemp(Bool)
        case rootDeleteDate(Date?)
        case isEmptySheet(Bool)
        case position(Int)
        case time(Double)
        case hasTheme(ThemeCodable?)
        case content(String?)
        case isBibleVers(Bool)
        case hasTitle(Bool)
        case imageBorderColor(String?)
        case imageBorderSize(Int16)
        case imageContentMode(Int16)
        case imageHasBorder(Bool)
        case imagePath(String?)
        case thumbnailPath(String?)
        case imagePathAWS(String?)
        case textLeft(String?)
        case textRight(String?)
        case imageSelectionAction(ImageSelectionAction)
    }
    
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
    private(set) var title: String? = nil
    private(set) var createdAt: Date = Date().localDate()
    private(set) var updatedAt: Date? = nil
    private(set) var deleteDate: Date? = nil
    private(set) var isTemp: Bool = false
    private(set) var rootDeleteDate: Date? = nil
    private(set) var isEmptySheet: Bool = false
    private(set) var position: Int = 0
    private(set) var time: Double = 0
    private(set) var hasTheme: ThemeCodable? = nil
    private(set) var content: String? = nil
    private(set) var isBibleVers: Bool = false
    private(set) var hasTitle: Bool = true
    private(set) var imageBorderColor: String? = nil
    private(set) var imageBorderSize: Int16 = 0
    private(set) var imageContentMode: Int16 = 0
    private(set) var imageHasBorder: Bool = false
    private(set) var imagePath: String? = nil
    private(set) var thumbnailPath: String? = nil
    private(set) var imagePathAWS: String? = nil
    private(set) var textLeft: String? = nil
    private(set) var textRight: String? = nil
    private(set) var imageSelectionAction: ImageSelectionAction = .none
    private(set) var hasThemeDraft: ThemeDraft
    private(set) var tempSavedImageName: String?

    var sheetImage: UIImage? {
        UIImage.get(imagePath: self.imagePath)
    }
    var sheetthumbnail: UIImage? {
        UIImage.get(imagePath: self.thumbnailPath)
    }
    var sheetImageBorderColor: UIColor? {
        UIColor(hex: imageBorderColor)
    }
    let sheetType: SheetType
    
    init(sheetTitleContent: SheetTitleContentCodable, isCustom: Bool = false) {
        sheetType = .SheetTitleContent
        self.id = sheetTitleContent.id
        self.userUID = sheetTitleContent.userUID
        self.title = sheetTitleContent.title
        self.createdAt = sheetTitleContent.createdAt
        self.updatedAt = sheetTitleContent.updatedAt
        self.deleteDate = sheetTitleContent.deleteDate
        self.rootDeleteDate = sheetTitleContent.rootDeleteDate
        self.isEmptySheet = sheetTitleContent.isEmptySheet
        self.position = sheetTitleContent.position
        self.time = sheetTitleContent.time
        self.hasTheme = sheetTitleContent.hasTheme
        self.content = sheetTitleContent.content
        self.isBibleVers = sheetTitleContent.isBibleVers
        if isCustom {
            hasThemeDraft = sheetTitleContent.hasTheme != nil ? ThemeDraft(theme: sheetTitleContent.hasTheme) : ThemeDraft(theme: ThemeCodable.makeDefault())
        } else {
            hasThemeDraft = ThemeDraft(theme: sheetTitleContent.hasTheme)
        }
    }
    
    init(sheetTitleImage: SheetTitleImageCodable) {
        sheetType = .SheetTitleImage
        self.id = sheetTitleImage.id
        self.userUID = sheetTitleImage.userUID
        self.title = sheetTitleImage.title
        self.createdAt = sheetTitleImage.createdAt
        self.updatedAt = sheetTitleImage.updatedAt
        self.deleteDate = sheetTitleImage.deleteDate
        self.rootDeleteDate = sheetTitleImage.rootDeleteDate
        self.isEmptySheet = sheetTitleImage.isEmptySheet
        self.position = sheetTitleImage.position
        self.time = sheetTitleImage.time
        self.hasTheme = sheetTitleImage.hasTheme
        self.content = sheetTitleImage.content
        self.hasTitle = sheetTitleImage.hasTitle
        self.imageBorderColor = sheetTitleImage.imageBorderColor
        self.imageBorderSize = sheetTitleImage.imageBorderSize
        self.imageContentMode = sheetTitleImage.imageContentMode
        self.imageHasBorder = sheetTitleImage.imageHasBorder
        self.imagePath = sheetTitleImage.imagePath
        self.thumbnailPath = sheetTitleImage.thumbnailPath
        self.imagePathAWS = sheetTitleImage.imagePathAWS
        hasThemeDraft = (sheetTitleImage.hasTheme != nil) ? ThemeDraft(theme: sheetTitleImage.hasTheme) : ThemeDraft(theme: .makeDefault())
    }
    
    init(sheetEmpty: SheetEmptyCodable) {
        sheetType = .SheetEmpty
        self.id = sheetEmpty.id
        self.userUID = sheetEmpty.userUID
        self.title = sheetEmpty.title
        self.createdAt = sheetEmpty.createdAt
        self.updatedAt = sheetEmpty.updatedAt
        self.deleteDate = sheetEmpty.deleteDate
        self.rootDeleteDate = sheetEmpty.rootDeleteDate
        self.isEmptySheet = sheetEmpty.isEmptySheet
        self.position = sheetEmpty.position
        self.time = sheetEmpty.time
        self.hasTheme = sheetEmpty.hasTheme
        hasThemeDraft = (sheetEmpty.hasTheme != nil) ? ThemeDraft(theme: sheetEmpty.hasTheme) : ThemeDraft(theme: .makeDefault())
    }
    
    init(sheetSplit: SheetSplitCodable) {
        sheetType = .SheetSplit
        self.id = sheetSplit.id
        self.userUID = sheetSplit.userUID
        self.title = sheetSplit.title
        self.createdAt = sheetSplit.createdAt
        self.updatedAt = sheetSplit.updatedAt
        self.deleteDate = sheetSplit.deleteDate
        self.rootDeleteDate = sheetSplit.rootDeleteDate
        self.isEmptySheet = sheetSplit.isEmptySheet
        self.position = sheetSplit.position
        self.time = sheetSplit.time
        self.hasTheme = sheetSplit.hasTheme
        self.textLeft = sheetSplit.textLeft
        self.textRight = sheetSplit.textRight
        hasThemeDraft = (sheetSplit.hasTheme != nil) ? ThemeDraft(theme: sheetSplit.hasTheme) : ThemeDraft(theme: .makeDefault())
    }
    
    init(sheetPastors: SheetPastorsCodable) {
        sheetType = .SheetPastors
        self.id = sheetPastors.id
        self.userUID = sheetPastors.userUID
        self.title = sheetPastors.title
        self.createdAt = sheetPastors.createdAt
        self.updatedAt = sheetPastors.updatedAt
        self.deleteDate = sheetPastors.deleteDate
        self.rootDeleteDate = sheetPastors.rootDeleteDate
        self.isEmptySheet = sheetPastors.isEmptySheet
        self.position = sheetPastors.position
        self.time = sheetPastors.time
        self.hasTheme = sheetPastors.hasTheme
        self.content = sheetPastors.content
        self.imagePath = sheetPastors.imagePath
        self.thumbnailPath = sheetPastors.thumbnailPath
        self.imagePathAWS = sheetPastors.imagePathAWS
        hasThemeDraft = (sheetPastors.hasTheme != nil) ? ThemeDraft(theme: sheetPastors.hasTheme) : ThemeDraft(theme: .makeDefault())
    }
    
    func update(_ cell: NewOrEditIphoneController.Cell) {
        switch cell {
        case .title(let value): title = value
        case .content(let value): content = value
        case .contentLeft(let value): textLeft = value
        case .contentRight(let value): textRight = value
        case .asTheme(let value): hasTheme = value.first
        
        case .image(let image, let imageName):
            updateImageSelection(image: image, imageName: imageName)
        case .pastorImage(let image, let imageName):
            updateImageSelection(image: image, imageName: imageName)
        case .hasBorder(let value): imageHasBorder = value
        case .imageBorderSize(let value): imageBorderSize = Int16(value)
        case .imageBorderColor(let value): imageBorderColor = value?.hexCode
        case .contentMode(let value): imageContentMode = Int16(value)
        default: break
        }
    }
    
    func hasAnyImage() -> Bool {
        switch imageSelectionAction {
        case .none: return imagePath != nil
        case .delete: return false
        case .image: return true
        }
    }
    
    func setImageSelectionAction(_ action: ImageSelectionAction, imageName: String?) {
        if let tempSavedImageName = tempSavedImageName {
            UIImage.deleteTempFile(imageName: tempSavedImageName, thumbNailName: nil)
        }
        tempSavedImageName = imageName
        self.imageSelectionAction = action
    }
    
    func makeCodable() throws -> CodableOutput {
        switch sheetType {
        case .SheetTitleContent:
            return .sheetTitleContent(SheetTitleContentCodable(
                id: id,
                userUID: userUID,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleteDate: deleteDate,
                rootDeleteDate: rootDeleteDate,
                isEmptySheet: isEmptySheet,
                position: position,
                time: time,
                hasTheme: try hasThemeDraft.makeCodable(),
                content: content,
                isBibleVers: isBibleVers
            ))
        case .SheetTitleImage:
            return .sheetTitleImage(SheetTitleImageCodable(
                id: id,
                userUID: userUID,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleteDate: deleteDate,
                rootDeleteDate: rootDeleteDate,
                isEmptySheet: isEmptySheet,
                position: position,
                time: time,
                hasTheme: try hasThemeDraft.makeCodable(),
                content: content,
                hasTitle: hasTitle,
                imageBorderColor: imageBorderColor,
                imageBorderSize: imageBorderSize,
                imageContentMode: imageContentMode,
                imageHasBorder: imageHasBorder,
                imagePath: imagePath,
                thumbnailPath: thumbnailPath,
                imagePathAWS: imagePathAWS
            ))
        case .SheetEmpty:
            return .sheetEmpty(SheetEmptyCodable(
                id: id,
                userUID: userUID,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleteDate: deleteDate,
                rootDeleteDate: rootDeleteDate,
                isEmptySheet: isEmptySheet,
                position: position,
                time: time,
                hasTheme: try hasThemeDraft.makeCodable()
            ))
        case .SheetSplit:
            return .sheetSplit(SheetSplitCodable(
                id: id,
                userUID: userUID,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleteDate: deleteDate,
                isTemp: isTemp,
                rootDeleteDate: rootDeleteDate,
                isEmptySheet: isEmptySheet,
                position: position,
                time: time,
                hasTheme: try hasThemeDraft.makeCodable(),
                textLeft: textLeft,
                textRight: textRight
            ))
        case .SheetPastors:
            return .sheetPastors(SheetPastorsCodable(
                id: id,
                userUID: userUID,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleteDate: deleteDate,
                isTemp: isTemp,
                rootDeleteDate: rootDeleteDate,
                isEmptySheet: isEmptySheet,
                position: position,
                time: time,
                hasTheme: try hasThemeDraft.makeCodable(),
                content: content,
                imagePath: imagePath,
                thumbnailPath: thumbnailPath,
                imagePathAWS: imagePathAWS
            ))
        case .SheetActivities:
            return .none
        }
    }
    
    private func updateImageSelection(image: UIImage?, imageName: String?) {
        if let image = image {
            setImageSelectionAction(.image(image), imageName: imageName)
        } else if imageSelectionAction.image != nil {
            setImageSelectionAction(.none, imageName: nil)
        } else {
            setImageSelectionAction(.delete, imageName: nil)
        }
    }
    
}
