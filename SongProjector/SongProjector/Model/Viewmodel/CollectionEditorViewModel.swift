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
    
    enum MenuItem: Identifiable {
        var id: String {
            return UUID().uuidString
        }
        case add
        case change
        case menu
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
    
    enum CollectionType: Equatable, CaseIterable, Identifiable {
        var id: String {
            return UUID().uuidString
        }
        case lyrics
        case bibleStudy
        case custom
        
        var title: String {
            switch self {
            case .lyrics: return AppText.CustomSheets.Menu.Lyrics
            case .bibleStudy: return AppText.CustomSheets.Menu.BibleSheets
            case .custom: return AppText.CustomSheets.Menu.Custom
            }
        }
    }
    
    let collectionType: CollectionType

    @Published var lyricsOrBibleStudyText: String = ""
    @Published var themeSelectionModel: ThemesSelectionModel
    @Published var tagsSelectionModel: TagSelectionModel

    @Published var cluster: ClusterCodable
    @Published var clusterStartTime: String = ""
    @Published var isNew = false
    @Published var title: String = ""
    
    @Published var isUniversalSong = false // has no save option
    @Published var sheets: [SheetViewModel] = []
    @Published var clusterTime: Int = 0
    @Published var error: LocalizedError?
    @Published var showingLoader = false
    @Published var instrumentsModel = InstrumentsModel()

    private var deletedSheets: [SheetViewModel] = []

    var hasOtherSheetTypes: Bool {
        sheets.filter { $0.themeModel.theme.isHidden }.count > 0
    }
    var showTimePickerScrollView: Bool {
        ![.bibleStudy, .lyrics].contains(collectionType) && !sheets.contains(where: { !$0.sheetTime.isBlanc }) && !instrumentsModel.instruments.contains(where: { $0.resourcePath != nil })
    }
    var canDeleteSheets: Bool {
        ![.bibleStudy, .lyrics].contains(collectionType)
    }
    var editActions: [MenuItem] {
        switch collectionType {
        case .lyrics: return sheets.count > 0 ? [.save, .change] : [.add]
        case .custom, .bibleStudy: return sheets.count > 0 ? [.save, .menu] : [.menu]
        }
    }
    
    init?(
        cluster: ClusterCodable?,
        themeSelectionModel: ThemesSelectionModel,
        tagsSelectionModel: TagSelectionModel,
        collectionType: CollectionType
    ) {
        guard let unwrappedCluster = cluster ?? .makeDefault() else {
            return nil
        }
        self.cluster = unwrappedCluster
        self.themeSelectionModel = themeSelectionModel
        self.tagsSelectionModel = tagsSelectionModel
        self.collectionType = collectionType
        self.clusterTime = cluster?.time.intValue ?? 0
        self.isNew = cluster == nil
        self.title = cluster?.title ?? ""
        self.clusterStartTime = String(unwrappedCluster.startTime)
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
                            
                        }.sorted(by: { $0.sheetModel.position < $1.sheetModel.position })
                        
                        switch collectionType {
                        case .lyrics:
                            lyricsOrBibleStudyText = GenerateLyricsSheetContentUseCase().getTextFrom(cluster: unwrappedCluster, models: sheets)
                        case .bibleStudy:
                            lyricsOrBibleStudyText = await BibleStudyTextUseCase().getTextFromSheets(models: sheets)
                        case .custom:
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
                await bibleStudyTextDidChange(
                    lyricsOrBibleStudytext: self.lyricsOrBibleStudyText,
                    updateExistingSheets: false,
                    parentViewSize: sheetSize
                )
                await updateCustomSheets()
            }
        case .lyrics:
            Task {
                await lyricsTextDidChange(screenWidth: sheetSize.width)
            }
        case .custom:
            return
        }
    }
    
    func bibleStudyTextDidChange(lyricsOrBibleStudytext: String, updateExistingSheets: Bool, parentViewSize: CGSize) async {
        var sheetsWithIndex: [(Int ,SheetViewModel)] = []
        for (index, sheet) in sheets.enumerated() {
            if !sheet.sheetModel.isBibleVers {
                sheetsWithIndex.append((index, sheet))
            }
        }
        let text = updateExistingSheets ? await getBibleStudyString() : lyricsOrBibleStudytext
        if text.count == 0 {
            self.deletedSheets = sheets
            sheets = []
        } else if text.count > 0, let theme = themeSelectionModel.selectedTheme {
            Task {
                let bibleStudyTitleContent = try await BibleStudyTextUseCase().generateSheetsFromText(
                    text,
                    parentViewSize: parentViewSize,
                    theme: theme,
                    scaleFactor: getScaleFactor(width: parentViewSize.width),
                    cluster: cluster,
                    addEmptySheetAfterBibleStudyText: cluster.showEmptySheetBibleText
                )
                
                var updatedSheets = bibleStudyTitleContent
                for indexWithSheet in sheetsWithIndex {
                    let (index, sheet) = indexWithSheet
                    print(index)
                    updatedSheets.insert(sheet, at: min(index, updatedSheets.count))
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
                for (index, model) in models.enumerated() {
                    model.sheetTime = sheets[safe: index]?.sheetTime ?? ""
                }
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
        if let index = sheets.firstIndex(where: { $0.sheetModel.sheet.id == model.sheetModel.sheet.id }) {
            sheets.remove(at: index)
            model.sheetModel.position = index
            sheets.insert(model, at: index)
        } else {
            model.sheetModel.position = sheets.count
            sheets.append(model)
        }
    }
        
    func generatePreviewCluster() throws -> ClusterCodable {
        var updatedCluster = cluster
        guard let selectedTheme = themeSelectionModel.selectedTheme else {
            error = Error.noThemeSelected
            showingLoader = false
            throw Error.noThemeSelected
        }
        
        guard !title.isBlanc else {
            error = Error.noTitle
            showingLoader = false
            throw Error.noTitle
        }
        
        do {
            var codableSheets: [SheetMetaType] = []
            for (index, sheet) in sheets.enumerated() {
                if var createdSheet = try sheet.createSheetCodable() {
                    createdSheet.position = index
                    codableSheets.append(createdSheet)
                    
                }
            }
            
            updatedCluster.title = title
            updatedCluster.startTime = Double(clusterStartTime) ?? 0.0
            updatedCluster.time = showTimePickerScrollView ? Double(clusterTime) : 0
            updatedCluster.hasTags = tagsSelectionModel.selectedTags
            updatedCluster.tagIds = tagsSelectionModel.selectedTags.compactMap { $0.id }
            updatedCluster.theme = selectedTheme
            updatedCluster.themeId = selectedTheme.id
            updatedCluster.hasSheets = codableSheets
            updatedCluster.hasInstruments = instrumentsModel.instruments.compactMap({ instrument in
                if let resourcePath = instrument.resourcePath?.absoluteString {
                    return InstrumentCodable(
                        isLoop: instrument.instrumentType == .pianoSolo,
                        resourcePath: resourcePath,
                        typeString: instrument.instrumentType.rawValue
                    )
                }
                return nil
            })
            return updatedCluster
            
        } catch {
            let locError = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
            self.error = locError
            throw locError
        }
    }
    
    func saveCluster() async -> Bool {
        var updatedCluster = cluster
        showingLoader = true
        guard let user = await GetUserUseCase().get() else {
            showingLoader = false
            return false
        }
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
                        
            updatedCluster.title = title
            updatedCluster.startTime = Double(clusterStartTime) ?? 0.0
            updatedCluster.time = showTimePickerScrollView ? Double(clusterTime) : 0
            updatedCluster.hasTags = tagsSelectionModel.selectedTags
            updatedCluster.tagIds = tagsSelectionModel.selectedTags.compactMap { $0.id }
            updatedCluster.theme = selectedTheme
            updatedCluster.themeId = selectedTheme.id
            updatedCluster.hasSheets = codableSheets
            updatedCluster.hasSheetPastors = sheets.contains(where: { $0.sheetModel.sheetType == .SheetPastors })
            
            if instrumentsModel.instruments.filter({ $0.resourcePath != nil }).count > 0 {
                updatedCluster.hasInstruments = try instrumentsModel.instruments
                    .compactMap { instrument in
                        guard let resourcePath = instrument.resourcePath else { return nil }
                        let fileName = GetFileNameUseCase(pathExtension: resourcePath.pathExtension).getFileName()
                        let tempURL = GetFileURLUseCase(fileName: fileName).getURL(location: .temp)
                        try FileManager.default.copyItem(at: resourcePath, to: tempURL)
                        return InstrumentCodable(resourcePath: fileName, typeString: instrument.instrumentType.rawValue)
                    }
            }
            var deleteObjects: [DeleteObject] {
                deletedSheets.compactMap { $0.sheetModel.sheet }.flatMap { $0.getDeleteObjects(forceDelete: true) }
            }
            
            if uploadSecret != nil {
                updatedCluster.contentPackage = ContentPackage(contentPackage: user.contentPackage) ?? ContentPackage(contentPackage: user.contentPackageBabyChurchesMotherChurch) ?? .user
            } else {
                updatedCluster.contentPackage = ContentPackage.user
            }
            let endpoint = await GetCollectionsEndpointUseCase().get()
            
            try await SubmitUseCase(endpoint: endpoint, requestMethod: isNew ? .post : .put, uploadObjects: [updatedCluster], deleteObjects: deleteObjects).submit()
            
            showingLoader = false
            return true

        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
            return false
        }
    }
    
    func canDelete(sheetViewModel: SheetViewModel) -> Bool {
        if sheetViewModel.sheetModel.sheet.isBibleVers {
            return false
        } else if (sheetViewModel.sheetModel.sheet as? SheetEmptyCodable)?.theme == nil {
            return false
        }
        return true
    }
    
    func canMove(_ sheetModel: SheetViewModel) -> Bool {
        Double(sheetModel.sheetTime) ?? 0 > 0
    }
    func move(from source: IndexSet, to destination: Int) {
        sheets.move(fromOffsets: source, toOffset: destination)
        for (index, sheet) in sheets.enumerated() {
            sheet.sheetModel.position = index
        }
    }
    
    private func updateCustomSheets() async {
        do {
            cluster.theme = themeSelectionModel.selectedTheme
            let theme = try await CreateThemeUseCase().create()
            sheets = try await sheets.concurrentCompactMap({ model in
                guard !model.sheetModel.isBibleVers else { return model }
                let updatedSheet = model.sheetModel.sheet.set(sheetTime: Double(model.sheetTime) ?? 0.0)
                let newModel = try await SheetViewModel(cluster: self.cluster, theme: model.themeModel.theme, defaultTheme: theme, sheet: updatedSheet, sheetType: model.sheetModel.sheetType, sheetEditType: model.sheetEditType)
                newModel.title = model.title
                newModel.sheetModel.position = model.sheetModel.position
                return newModel
            }).sorted(by: { $0.sheetModel.position < $1.sheetModel.position })
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
}
