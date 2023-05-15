//
//  ClusterEditorModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct ClusterEditorModel {
    
    enum EditController: Equatable {
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
    
    var editController: EditController = .none

    var cluster: ClusterCodable
    var isNew = false
    var title: String = ""
    
    var isBibleVerses = false
    var isLyrics = false
    var isUniversalSong = false // has no save option
    var sheets: [EditSheetOrThemeViewModel]
    var selectedClusterTheme: ThemeCodable? { mutating didSet { updateSheets() } }
    var selectedTags: [TagCodable] = []
    var customSheetsEditModel: WrappedStruct<EditSheetOrThemeViewModel>? {
        if let type = editController.sheetType, let sheet = editController.sheet, let model = EditSheetOrThemeViewModel(editMode: .sheet((cluster, sheet), sheetType: type), isUniversal: uploadSecret != nil, isCustomSheetType: true) {
            return WrappedStruct(withItem: model)
        } else {
            return nil
        }
    }
    
    init?(cluster: ClusterCodable?) {
        guard let unwrappedCluster = cluster ?? .makeDefault() else {
            return nil
        }
        self.cluster = unwrappedCluster
        self.isNew = cluster == nil
        self.title = cluster?.title ?? ""
        self.isBibleVerses = cluster?.hasBibleVerses ?? false
        self.isLyrics = cluster?.isTypeSong ?? false
        self.isUniversalSong = uploadSecret != nil
        if let cluster = cluster {
            self.sheets = (cluster.hasSheets).compactMap { EditSheetOrThemeViewModel(editMode: .sheet((cluster, $0), sheetType: $0.sheetType ), isUniversal: uploadSecret != nil) }
        } else {
            self.sheets = []
        }
        selectedClusterTheme = unwrappedCluster.theme
        selectedTags = unwrappedCluster.hasTags
    }
    
    private mutating func updateSheets() {
        cluster.theme = selectedClusterTheme
        sheets = sheets.compactMap({ sheet in
            switch sheet.editMode {
            case .sheet(let clusterAndSheet, sheetType: let sheetType):
                if let extracted = clusterAndSheet {
                    var (cluster, sheet) = extracted
                    cluster.theme = selectedClusterTheme
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
        
    mutating func bibleStudyTextDidChange(_ text: String, contentTextViewContentSize: CGSize, scaleFactor: CGFloat) {
        if text.count > 0, let theme = selectedClusterTheme {
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
    
    mutating func lyricsTextDidChange(_ text: String, screenWidth: CGFloat) {
        if text.count > 0 {
            cluster.title = GenerateLyricsSheetContentUseCase.getTitle(from: text)
            title = cluster.title ?? ""
            let sheets = GenerateLyricsSheetContentUseCase.buildSheets(fromText: text, cluster: cluster)
            self.sheets = sheets
        }
    }
}

struct ThemesSelectionModel {
    
    private(set) var selectedTheme: ThemeCodable?
    private(set) var themes: [ThemeCodable] = []
    private let didSelectTheme: ((ThemeCodable?) -> Void)
    
    init(selectedTheme: ThemeCodable?, didSelectTheme: @escaping ((ThemeCodable?) -> Void)) {
        self.selectedTheme = selectedTheme
        self.didSelectTheme = didSelectTheme
        let persitedThemes: [Theme] = DataFetcher().getEntities(moc: moc, sort: NSSortDescriptor(key: "position", ascending: true))
        
        themes = persitedThemes.compactMap { ThemeCodable(managedObject: $0, context: moc) }
    }
    
    mutating func didSelect(theme: ThemeCodable?) {
        selectedTheme = selectedTheme?.id == theme?.id ? nil : theme
        didSelectTheme(selectedTheme)
    }
        
    func loadData() {
        
        
        
    }
}

struct TagsSelectionModel {
    
    let label: String
    private(set) var selectedTags: [TagCodable]
    private let didSelectTags: (([TagCodable]) -> Void)
    private(set) var tags: [TagCodable] = []
    
    init(label: String, selectedTags: [TagCodable], didSelectTags: @escaping (([TagCodable]) -> Void)) {
        self.label = label
        self.didSelectTags = didSelectTags
        self.selectedTags = selectedTags
        
        let persitedThemes: [Tag] = DataFetcher().getEntities(moc: moc, sort: NSSortDescriptor(key: "position", ascending: true))
        
        tags = persitedThemes.compactMap { TagCodable(managedObject: $0, context: moc) }
    }
    
    mutating func didSelectTag(_ tag: TagCodable) {
        if selectedTags.contains(where: { $0.id == tag.id }) {
            selectedTags.removeAll(where: { $0.id == tag.id })
        } else {
            selectedTags.append(tag)
        }
    }
    
    func loadData() {
        
    }
}

