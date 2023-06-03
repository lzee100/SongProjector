//
//  SaveSheetsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor SaveSheetsUseCase {
    
    private let context = newMOCBackground
    
    func save(entities: [SheetMetaType]) async throws {
        
        try await context.perform {
            try entities.forEach { sheet in
                
                if let sheet = sheet as? SheetTitleContentCodable {
                    try self.getSheetTitleContent(sheet)
                } else if let sheet = sheet as? SheetTitleImageCodable {
                    try self.getSheetTitleImage(sheet)
                } else if let sheet = sheet as? SheetPastorsCodable {
                    try self.getSheetPastors(sheet)
                } else if let sheet = sheet as? SheetSplitCodable {
                    try self.getSheetSplit(sheet)
                } else if let sheet = sheet as? SheetEmptyCodable {
                    try self.getSheetEmpty(sheet)
                } else if let sheet = sheet as? SheetActivitiesCodable {
                    try self.getSheetActivities(sheet)
                }
            }
            try self.context.save()
        }
    }
    
    
    // MARK: - Sheet title content
    
    @discardableResult
    private func getSheetTitleContent(_ sheet: SheetTitleContentCodable) throws -> NSManagedObject {
        
        let sheetTitleContent: [SheetTitleContentEntity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: sheet.id)], fetchDeleted: true)
        
        if let entity = sheetTitleContent.first {
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        } else {
            let entity: SheetTitleContentEntity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        }
    }

    private func setProperties(fromSheet sheet: SheetTitleContentCodable, to entity: SheetTitleContentEntity) throws {
        entity.id = sheet.id
        entity.userUID = sheet.userUID
        entity.title = sheet.title
        entity.createdAt = sheet.createdAt.nsDate
        entity.updatedAt = sheet.updatedAt?.nsDate
        entity.deleteDate = sheet.deleteDate?.nsDate
        entity.rootDeleteDate = sheet.rootDeleteDate?.nsDate
        
        entity.content = sheet.content
        entity.isBibleVers = sheet.isBibleVers
        
        entity.isEmptySheet = sheet.isEmptySheet
        entity.position = Int16(sheet.position)
        entity.time = sheet.time
        
        if let theme = sheet.hasTheme {
            entity.hasTheme = try GetThemeEntityUseCase.get(theme, context: context)
        }
    }
    
    // MARK: - Sheet image
    
    @discardableResult
    private func getSheetTitleImage(_ sheet: SheetTitleImageCodable) throws -> NSManagedObject {
        
        let sheetTitleImage: [SheetTitleImageEntity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: sheet.id)], fetchDeleted: true)
        
        if let entity = sheetTitleImage.first {
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        } else {
            let entity: SheetTitleImageEntity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        }
    }

    private func setProperties(fromSheet codable: SheetTitleImageCodable, to entity: SheetTitleImageEntity) throws {
        entity.id = codable.id
        entity.userUID = codable.userUID
        entity.title = codable.title
        entity.createdAt = codable.createdAt.nsDate
        entity.updatedAt = codable.updatedAt?.nsDate
        entity.deleteDate = codable.deleteDate?.nsDate
        entity.rootDeleteDate = codable.rootDeleteDate?.nsDate

        entity.isEmptySheet = codable.isEmptySheet
        entity.position = Int16(codable.position)
        entity.time = codable.time
        
        entity.content = codable.content
        entity.hasTitle = codable.hasTitle
        entity.imageBorderColor = codable.imageBorderColor
        entity.imageBorderSize = codable.imageBorderSize
        entity.imageContentMode = codable.imageContentMode
        entity.imageHasBorder = codable.imageHasBorder
        entity.imagePath = codable.imagePath
        entity.thumbnailPath = codable.thumbnailPath
        entity.imagePathAWS = codable.imagePathAWS

        if let theme = codable.hasTheme {
            entity.hasTheme = try GetThemeEntityUseCase.get(theme, context: context)
        }
    }
    
    
    // MARK: - Sheet pastors
    
    @discardableResult
    private func getSheetPastors(_ sheet: SheetPastorsCodable) throws -> NSManagedObject {
        
        let sheetsPastor: [SheetPastorsEntity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: sheet.id)], fetchDeleted: true)
        
        if let entity = sheetsPastor.first {
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        } else {
            let entity: SheetPastorsEntity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        }
    }

    private func setProperties(fromSheet sheet: SheetPastorsCodable, to entity: SheetPastorsEntity) throws {
        entity.id = sheet.id
        entity.userUID = sheet.userUID
        entity.title = sheet.title
        entity.createdAt = sheet.createdAt.nsDate
        entity.updatedAt = sheet.updatedAt?.nsDate
        entity.deleteDate = sheet.deleteDate?.nsDate
        entity.rootDeleteDate = sheet.rootDeleteDate?.nsDate

        entity.isEmptySheet = sheet.isEmptySheet
        entity.position = Int16(sheet.position)
        entity.time = sheet.time
        
        entity.content = sheet.content
        entity.imagePath = sheet.imagePath
        entity.thumbnailPath = sheet.thumbnailPath
        entity.imagePathAWS = sheet.imagePathAWS
        
        if let theme = sheet.hasTheme {
            entity.hasTheme = try GetThemeEntityUseCase.get(theme, context: context)
        }
    }
    
    // MARK: - Sheet empty
    
    @discardableResult
    private func getSheetEmpty(_ sheet: SheetEmptyCodable) throws -> NSManagedObject {
        
        let sheetsEmpty: [SheetEmptyEntity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: sheet.id)], fetchDeleted: true)
        
        if let entity = sheetsEmpty.first {
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        } else {
            let entity: SheetEmptyEntity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        }
    }

    private func setProperties(fromSheet sheet: SheetEmptyCodable, to entity: SheetEmptyEntity) throws {
        entity.id = sheet.id
        entity.userUID = sheet.userUID
        entity.title = sheet.title
        entity.createdAt = sheet.createdAt.nsDate
        entity.updatedAt = sheet.updatedAt?.nsDate
        entity.deleteDate = sheet.deleteDate?.nsDate
        entity.rootDeleteDate = sheet.rootDeleteDate?.nsDate

        entity.isEmptySheet = sheet.isEmptySheet
        entity.position = Int16(sheet.position)
        entity.time = sheet.time
        
        if let theme = sheet.hasTheme {
            entity.hasTheme = try GetThemeEntityUseCase.get(theme, context: context)
        }
    }
    
    
    // MARK: - Sheet Split
    
    @discardableResult
    private func getSheetSplit(_ sheet: SheetSplitCodable) throws -> NSManagedObject {
        
        let sheetsEmpty: [SheetSplitEntity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: sheet.id)], fetchDeleted: true)
        
        if let entity = sheetsEmpty.first {
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        } else {
            let entity: SheetSplitEntity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        }
    }
    
    private func setProperties(fromSheet sheet: SheetSplitCodable, to entity: SheetSplitEntity) throws {
        entity.id = sheet.id
        entity.userUID = sheet.userUID
        entity.title = sheet.title
        entity.createdAt = sheet.createdAt.nsDate
        entity.updatedAt = sheet.updatedAt?.nsDate
        entity.deleteDate = sheet.deleteDate?.nsDate
        entity.rootDeleteDate = sheet.rootDeleteDate?.nsDate
        
        entity.isEmptySheet = sheet.isEmptySheet
        entity.position = Int16(sheet.position)
        entity.time = sheet.time
        
        entity.textLeft = sheet.textLeft
        entity.textRight = sheet.textRight
        
        if let theme = sheet.hasTheme {
            entity.hasTheme = try GetThemeEntityUseCase.get(theme, context: context)
        }
    }
    
    // MARK: - Sheet activities
    
    @discardableResult
    private func getSheetActivities(_ sheet: SheetActivitiesCodable) throws -> NSManagedObject {
        
        let sheets: [SheetActivitiesEntity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: sheet.id)], fetchDeleted: true)
        
        if let entity = sheets.first {
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        } else {
            let entity: SheetActivitiesEntity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        }
    }

    private func setProperties(fromSheet sheet: SheetActivitiesCodable, to entity: SheetActivitiesEntity) throws {
        entity.id = sheet.id
        entity.userUID = sheet.userUID
        entity.title = sheet.title
        entity.createdAt = sheet.createdAt.nsDate
        entity.updatedAt = sheet.updatedAt?.nsDate
        entity.deleteDate = sheet.deleteDate?.nsDate
        entity.rootDeleteDate = sheet.rootDeleteDate?.nsDate
        entity.position = Int16(sheet.position)
        
        entity.hasGoogleActivity = NSSet(array: try sheet.hasGoogleActivities.compactMap { try getGoogleActivity($0) })
    }
    
    @discardableResult
    private func getGoogleActivity(_ sheet: GoogleActivityCodable) throws -> NSManagedObject {
        
        let sheets: [GoogleActivity] = try FetchPersistantEntitiesUseCase.fetchPersistend(context: context, predicates: [.get(id: sheet.id)], fetchDeleted: true)
        
        if let entity = sheets.first {
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        } else {
            let entity: GoogleActivity = CreatePersistentEntityUseCase.create(context: context)
            try setProperties(fromSheet: sheet, to: entity)
            return entity
        }
    }

    private func setProperties(fromSheet sheet: GoogleActivityCodable, to entity: GoogleActivity) throws {
        entity.id = sheet.id
        entity.userUID = sheet.userUID
        entity.title = sheet.title
        entity.createdAt = sheet.createdAt.nsDate
        entity.updatedAt = sheet.updatedAt?.nsDate
        entity.deleteDate = sheet.deleteDate?.nsDate
        entity.rootDeleteDate = sheet.rootDeleteDate?.nsDate
        
        entity.endDate = sheet.endDate?.nsDate
        entity.eventDescription = sheet.eventDescription
        entity.startDate = sheet.startDate?.nsDate
    }
    
}
