//
//  SaveThemeUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

struct GetThemeEntityUseCase {
    
    @discardableResult
    static func get(_ theme: ThemeCodable, context: NSManagedObjectContext) throws -> Theme {
        
        let themes: [Theme] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: theme.id)], fetchDeleted: true)
        
        if let entity = themes.first {
            setProperties(fromSheet: theme, to: entity)
            return entity
        } else {
            
            let entity: Theme = CreatePersistentEntityUseCase.create(context: context)
            setProperties(fromSheet: theme, to: entity)
            return entity
        }
    }

    private static func setProperties(fromSheet theme: ThemeCodable, to entity: Theme) {
        entity.id = theme.id
        entity.userUID = theme.userUID
        entity.title = theme.title
        entity.createdAt = theme.createdAt.nsDate
        entity.updatedAt = theme.updatedAt?.nsDate
        entity.deleteDate = theme.deleteDate?.nsDate
        entity.rootDeleteDate = theme.rootDeleteDate?.nsDate

        entity.allHaveTitle = theme.allHaveTitle
        entity.backgroundColor = theme.backgroundColor
        entity.backgroundTransparancyNumber = theme.backgroundTransparancyNumber
        entity.displayTime = theme.displayTime
        entity.hasEmptySheet = theme.hasEmptySheet
        entity.imagePath = theme.imagePath
        entity.imagePathThumbnail = theme.imagePathThumbnail
        entity.isEmptySheetFirst = theme.isEmptySheetFirst
        entity.isHidden = theme.isHidden
        entity.isContentBold = theme.isContentBold
        entity.isContentItalic = theme.isContentItalic
        entity.isContentUnderlined = theme.isContentUnderlined
        entity.isTitleBold = theme.isTitleBold
        entity.isTitleItalic = theme.isTitleItalic
        entity.isTitleUnderlined = theme.isTitleUnderlined
        entity.contentAlignmentNumber = theme.contentAlignmentNumber
        entity.contentBorderColorHex = theme.contentBorderColorHex
        entity.contentBorderSize = theme.contentBorderSize
        entity.contentFontName = theme.contentFontName
        entity.contentTextColorHex = theme.contentTextColorHex
        entity.contentTextSize = theme.contentTextSize
        entity.position = Int16(theme.position)
        entity.titleAlignmentNumber = theme.titleAlignmentNumber
        entity.titleBackgroundColor = theme.titleBackgroundColor
        entity.titleBorderColorHex = theme.titleBorderColorHex
        entity.titleBorderSize = theme.titleBorderSize
        entity.titleFontName = theme.titleFontName
        entity.titleTextColorHex = theme.titleTextColorHex
        entity.titleTextSize = theme.titleTextSize
        entity.imagePathAWS = theme.imagePathAWS
        entity.isUniversal = theme.isUniversal
        entity.isDeletable = theme.isDeletable
    }
}
