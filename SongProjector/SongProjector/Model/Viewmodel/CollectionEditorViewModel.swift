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
    
    enum CollectionType: Equatable {
        case none
        case lyrics
        case bibleStudy
        case customSheet(type: SheetType)
        
        var sheet: SheetMetaType? {
            switch self {
            case .customSheet(type: let type):
                return type.makeDefault()
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
    }
    
    @Published var themeSelectionModel: ThemesSelectionModel
    @Published var tagsSelectionModel: TagSelectionModel
    
    @Published var collectionType: CollectionType = .none
    @Published var cluster: ClusterCodable
    @Published var isNew = false
    @Published var title: String = ""
    
    @Published var isBibleVerses = false
    @Published var isLyrics = false
    @Published var isUniversalSong = false // has no save option
    @Published var sheets: [EditSheetOrThemeViewModel]
    @Published var clusterTime: Int = 0
    @Published var error: LocalizedError?

    var customSheetsEditModel: WrappedStruct<EditSheetOrThemeViewModel>? {
        if let type = collectionType.sheetType, let sheet = collectionType.sheet, let model = EditSheetOrThemeViewModel(editMode: .sheet((cluster, sheet), sheetType: type), isUniversal: uploadSecret != nil, isCustomSheetType: true) {
            return WrappedStruct(withItem: model)
        } else {
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
        self.isBibleVerses = cluster?.hasBibleVerses ?? false
        self.isLyrics = cluster?.isTypeSong ?? false
        self.isUniversalSong = uploadSecret != nil
        if let cluster = cluster {
            self.sheets = (cluster.hasSheets.sorted(by: { $0.position < $1.position })).compactMap { EditSheetOrThemeViewModel(editMode: .sheet((cluster, $0), sheetType: $0.sheetType ), isUniversal: uploadSecret != nil) }
        } else {
            self.sheets = []
        }
    }
    
    func updateSheets() {
        cluster.theme = themeSelectionModel.selectedTheme
        sheets = sheets.compactMap({ sheet in
            switch sheet.editMode {
            case .sheet(let clusterAndSheet, sheetType: let sheetType):
                if let extracted = clusterAndSheet {
                    var (cluster, sheet) = extracted
                    cluster.theme = themeSelectionModel.selectedTheme
                    if let model = EditSheetOrThemeViewModel(editMode: .sheet((cluster, sheet), sheetType: sheetType), isUniversal: uploadSecret != nil) {
                        return model
                    }
                    return nil
                }
                return nil
            case .theme: return nil
            }
        })
    }
    
    func getIndexOf(_ model: EditSheetOrThemeViewModel) -> Int? {
        sheets.firstIndex(where: { $0.sheet.id == model.sheet.id })
    }
        
    func bibleStudyTextDidChange(_ text: String, contentTextViewContentSize: CGSize, scaleFactor: CGFloat) {
        if text.count > 0, let theme = themeSelectionModel.selectedTheme {
            let bibleStudyTitleContent =  BibleStudyTextUseCase.generateSheetsFromText(
                text,
                contentSize: contentTextViewContentSize,
                theme: theme,
                scaleFactor: scaleFactor,
                cluster: cluster
            )
            sheets = bibleStudyTitleContent // TODO: ADD EMPTY SHEETS BASED ON THEME SETTINGS
        }
    }
    
    func lyricsTextDidChange(_ text: String, screenWidth: CGFloat) {
        if text.count > 0 {
            cluster.title = GenerateLyricsSheetContentUseCase.getTitle(from: text)
            title = cluster.title ?? ""
            let sheets = GenerateLyricsSheetContentUseCase.buildSheets(fromText: text, cluster: cluster)
            self.sheets = sheets
        }
    }
    
    func getLyricsOrBibleStudyString() -> String {
        let sheetContents = sheets.compactMap { $0.sheet.sheetContent }.joined(separator: "\n\n")
        return [title, sheetContents].joined(separator: "\n\n")
    }
    
    func saveCluster() {
        guard let selectedTheme = themeSelectionModel.selectedTheme else {
            return
        }
        do {
            var codableSheets: [SheetMetaType] = []
            for sheet in sheets {
                var saveableSheet = sheet
                if let createdSheet = try saveableSheet.createSheetCodable() {
                    codableSheets.append(createdSheet)
                }
            }
            
            cluster.title = title
            cluster.hasTags = tagsSelectionModel.selectedTags
            cluster.theme = selectedTheme
            cluster.hasSheets = codableSheets
            
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
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
    
}

@MainActor class ThemesSelectionModel: ObservableObject {
    
    @Published private(set) var selectedTheme: ThemeCodable?
    @Published private(set) var themes: [ThemeCodable] = []
    
    init(selectedTheme: ThemeCodable?) {
        self.selectedTheme = selectedTheme
        let persitedThemes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: [.skipHidden], sort: NSSortDescriptor(key: "position", ascending: true))
        
        themes = persitedThemes.compactMap { ThemeCodable(managedObject: $0, context: moc) }
    }
    
    func didSelect(theme: ThemeCodable?) {
        selectedTheme = selectedTheme?.id == theme?.id ? nil : theme
    }
    
    func fetchRemoteThemes() {
    }
    
}
