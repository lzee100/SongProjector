//
//  ClusterEditorModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor class CollectionEditorViewModel: ObservableObject {
    
    enum EditAction: Identifiable {
        var id: String {
            return UUID().uuidString
        }
        case add
        case change
        case save
    }
    
    enum Error: LocalizedError {
        case noThemeSelected
        case noTitle
        case loseOtherSheets

        var errorDescription: String? {
            switch self {
            case .noThemeSelected: return AppText.NewSong.erorrMessageNoTheme
            case .noTitle: return AppText.NewSong.errorNoTitle
            case .loseOtherSheets: return AppText.CustomSheets.errorLoseOtherSheets
            }
        }
    }
    
    enum CollectionType: Equatable {
        case none
        case lyrics
        case bibleStudy
        case customSheet(type: SheetType)
        
        func sheet() async -> SheetMetaType? {
            switch self {
            case .customSheet(type: let type):
                return await type.makeDefault()
            default: return nil
            }
        }
        
        var sheetType: SheetType? {
            switch self {
            case .customSheet(type: let type):
                return type
            default: return nil
            }
        }
        var isBibleStudy: Bool {
            switch self {
            case .bibleStudy: return true
            case .none, .lyrics, .customSheet: return false
            }
        }
        var isCustomType: Bool {
            switch self {
            case .customSheet: return true
            default: return false
            }
        }
    }
    
    var lyricsOrBibleStudyText: String = ""
    @Published var themeSelectionModel: ThemesSelectionModel
    @Published var tagsSelectionModel: TagSelectionModel

    @Published private(set) var collectionType: CollectionType = .none
    @Published var cluster: ClusterCodable
    @Published var isNew = false
    @Published var title: String = ""
    
    @Published var isUniversalSong = false // has no save option
    @Published var sheets: [SheetViewModel] = []
    private var deletedSheets: [SheetViewModel] = []
    @Published var clusterTime: Int = 0
    @Published var error: LocalizedError?
    @Published var showingLoader = false
    
    var hasOtherSheetTypes: Bool {
        sheets.filter { $0.themeModel.theme.isHidden }.count > 0
    }
    var showTimePickerScrollView: Bool {
        ![.bibleStudy, .lyrics].contains(collectionType)
    }
    var canDeleteSheets: Bool {
        ![.bibleStudy, .lyrics].contains(collectionType)
    }
    var editActions: [EditAction] {
        let optionalSaveAction: [EditAction] = sheets.count > 0 ? [.save] : []
        if case .lyrics = collectionType {
            return optionalSaveAction + [.change]
        } else {
            return optionalSaveAction + [.add]
        }
    }
    
    func customSheetsEditModel(collectionType: CollectionType) async -> SheetViewModel? {
        do {
            let defaultTheme = try await CreateThemeUseCase().create(isHidden: true)
            var sheet = await collectionType.sheet()
            sheet = sheet?.set(theme: defaultTheme)
            if let type = collectionType.sheetType, let sheet = sheet {
                return try await SheetViewModel(cluster: cluster, theme: sheet.theme, defaultTheme: defaultTheme, sheet: sheet, sheetType: type, sheetEditType: .custom)
            } else {
                return nil
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
            return nil
        }
    }

    init?(cluster: ClusterCodable?, themeSelectionModel: ThemesSelectionModel, tagsSelectionModel: TagSelectionModel) {
        guard let unwrappedCluster = cluster ?? .makeDefault() else {
            return nil
        }
        self.cluster = unwrappedCluster
        self.themeSelectionModel = themeSelectionModel
        self.tagsSelectionModel = tagsSelectionModel
        self.clusterTime = cluster?.time.intValue ?? 0
        self.collectionType = Self.editControllerType(for: cluster)
        self.isNew = cluster == nil
        self.title = cluster?.title ?? ""
        self.isUniversalSong = uploadSecret != nil
        
        defer {
            Task {
                do {
                    let defaultTheme = try await CreateThemeUseCase().create()
                    if let cluster = cluster {
                        self.sheets = try await (cluster.hasSheets.sorted(by: { $0.position < $1.position })).asyncMap {
                            
                            return try await SheetViewModel(
                                cluster: cluster,
                                theme: nil,
                                defaultTheme: defaultTheme,
                                sheet: $0,
                                sheetType: $0.sheetType,
                                sheetEditType: collectionType == .lyrics ? .lyrics : collectionType == .bibleStudy ? .bibleStudy : .custom
                            )
                            
                        }
                        switch collectionType {
                        case .lyrics:
                            lyricsOrBibleStudyText = GenerateLyricsSheetContentUseCase().getTextFrom(cluster: unwrappedCluster, models: sheets)
                        case .bibleStudy:
                            lyricsOrBibleStudyText = await BibleStudyTextUseCase().getTextFromSheets(models: sheets)
                        case .none, .customSheet:
                            break
                        }
                    } else {
                        self.sheets = []
                    }
                } catch {
                    self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
                }
            }
        }
    }
    
    func updateSheets(sheetSize: CGSize) {
        cluster.theme = themeSelectionModel.selectedTheme
        
        switch collectionType {
        case .bibleStudy:
            Task {
                await bibleStudyTextDidChange(updateExistingSheets: false, parentViewSize: sheetSize)
                await updateCustomSheets()
            }
        case .lyrics:
            Task {
                await lyricsTextDidChange(screenWidth: sheetSize.width)
            }
        case .customSheet:
            return
        case .none:
            return
        }
    }
    
    func bibleStudyTextDidChange(updateExistingSheets: Bool, parentViewSize: CGSize) async {
        var sheetsWithIndex = [(Int ,SheetViewModel)]()
        for (index, sheet) in sheets.enumerated() {
            if !sheet.sheetModel.isBibleVers {
                sheetsWithIndex.append((index, sheet))
            }
        }
        let text = updateExistingSheets ? await getBibleStudyString() : lyricsOrBibleStudyText
        if text.count > 0, let theme = themeSelectionModel.selectedTheme {
            Task {
                let bibleStudyTitleContent = try await BibleStudyTextUseCase().generateSheetsFromText(
                    text,
                    parentViewSize: parentViewSize,
                    theme: theme,
                    scaleFactor: getScaleFactor(width: parentViewSize.width),
                    cluster: cluster
                )
                
                var updatedSheets = bibleStudyTitleContent
                for indexWithSheet in sheetsWithIndex {
                    let (index, sheet) = indexWithSheet
                    updatedSheets.insert(sheet, at: index)
                }
                self.sheets = updatedSheets
            }
        }
    }
        
    func lyricsTextDidChange(screenWidth: CGFloat) async {
        do {
            let lyrics = lyricsOrBibleStudyText
            if lyrics.count > 0 {
                title = GenerateLyricsSheetContentUseCase().getTitle(from: lyrics)
                cluster.title = title
                let models = try await GenerateLyricsSheetContentUseCase().buildSheetsModels(from: lyrics, cluster: cluster)
                sheets = models
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func getBibleStudyString() async -> String {
        return await BibleStudyTextUseCase().getTextFromSheets(models: sheets)
    }
    
    func getLyricsString() -> String {
        return GenerateLyricsSheetContentUseCase().getTextFrom(cluster: cluster, models: sheets)
    }

    func delete(model: SheetViewModel) {
        guard let index = sheets.firstIndex(where: { $0.sheetModel.sheet.id == model.sheetModel.sheet.id }) else { return }
        if !model.sheetModel.isNew {
            deletedSheets.append(model)
        }
        sheets.remove(at: index)
    }
    
    func deleteAllSheets() {
        deletedSheets = []
        sheets.forEach { model in
            if !model.sheetModel.isNew {
                deletedSheets.append(model)
            }
        }
        sheets = []
    }
    
    func deleteOtherSheetsThanBibleStudy() {
        deletedSheets += sheets.filter { !$0.sheetModel.isBibleVers }
    }
    
    func add(_ model: SheetViewModel) {
        var model = model
        if let index = sheets.firstIndex(where: { $0.sheetModel.sheet.id == model.sheetModel.sheet.id }) {
            sheets.remove(at: index)
            model.sheetModel.position = index
            sheets.insert(model, at: index)
        } else {
            model.sheetModel.position = sheets.count
            sheets.append(model)
        }
    }
    
    func update(collectionType: CollectionType) {
        guard collectionType != self.collectionType else { return }
        if case .customSheet = collectionType, self.collectionType == .bibleStudy {
            // dont change when custom sheet is added to biblestudy
        } else if [.bibleStudy, .lyrics].contains(collectionType) {
            self.collectionType = collectionType
            deletedSheets += sheets
        } else {
            self.collectionType = collectionType
        }
    }
    
    func saveCluster() async -> Bool {
        showingLoader = true
        guard let selectedTheme = themeSelectionModel.selectedTheme else {
            error = Error.noThemeSelected
            showingLoader = false
            return false
        }
        
        guard !title.isBlanc else {
            error = Error.noTitle
            showingLoader = false
            return false
        }
        
        do {
            var codableSheets: [SheetMetaType] = []
            for (index, sheet) in sheets.enumerated() {
                if var createdSheet = try sheet.createSheetCodable() {
                    createdSheet.position = index
                    codableSheets.append(createdSheet)
                    
                }
            }
            
            cluster.title = title
            cluster.time = showTimePickerScrollView ? Double(clusterTime) : 0
            cluster.hasTags = tagsSelectionModel.selectedTags
            cluster.tagIds = tagsSelectionModel.selectedTags.compactMap { $0.id }
            cluster.theme = selectedTheme
            cluster.themeId = selectedTheme.id
            cluster.hasSheets = codableSheets
            
            var deleteObjects: [DeleteObject] {
                deletedSheets.compactMap { $0.sheetModel.sheet }.flatMap { $0.getDeleteObjects(forceDelete: true) }
            }
            
            try await SubmitUseCase(endpoint: .clusters, requestMethod: isNew ? .post : .put, uploadObjects: [cluster], deleteObjects: deleteObjects).submit()
            showingLoader = false
            return true
            
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
            return false
        }
    }
    
    private static func editControllerType(for cluster: ClusterCodable?) -> CollectionType {
        guard let cluster else { return .none }
        if cluster.isTypeSong {
            return .lyrics
        } else if cluster.hasBibleVerses {
            return .bibleStudy
        }
        return .none
    }
    
    private func updateCustomSheets() async {
        do {
            cluster.theme = themeSelectionModel.selectedTheme
            let theme = try await CreateThemeUseCase().create()
            sheets = try await sheets.concurrentCompactMap({ model in
                guard !model.sheetModel.isBibleVers else { return model }
                return try await SheetViewModel(cluster: self.cluster, theme: model.themeModel.theme, defaultTheme: theme, sheet: model.sheetModel.sheet, sheetType: model.sheetModel.sheetType, sheetEditType: model.sheetEditType)
            })
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
}
