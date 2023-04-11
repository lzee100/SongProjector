//
//  CreateEditSheetSplitViewModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

class CreateEditSheetSplitViewModel: CreateEditThemeSheetViewModelProtocol {
    
    enum Mode {
        case new(SheetDraft)
        case edit(SheetDraft)
        
        var sheetDraft: SheetDraft {
            switch self {
            case .new(let sheetDraft): return sheetDraft
            case .edit(let sheetDraft): return sheetDraft
            }
        }
    }
    
    var displayTime: Bool {
        mode.sheetDraft.hasThemeDraft.displayTime
    }
    
    private weak var delegate: CreateEditThemeViewModelDelegate?
    private let mode: Mode
    private let sections: [NewOrEditIphoneController.Section]  = [.input, .general, .title, .content]
    
    private var inputRows: [NewOrEditIphoneController.Cell] {
        [
            .title(sheetDraft.title ?? AppText.NewTheme.sampleTitle),
            .contentLeft(sheetDraft.textLeft ?? AppText.NewTheme.sampleLyrics),
            .contentRight(sheetDraft.textRight ?? AppText.NewTheme.sampleLyrics)
        ]
    }
    private var generalRows: [NewOrEditIphoneController.Cell] {
        let themes: [Theme] = DataFetcher().getEntities(moc: moc)

        let sheetCells: [NewOrEditIphoneController.Cell] = [
            .asTheme(themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }),
            .backgroundColor(sheetDraft.hasThemeDraft.sheetBackgroundColor),
            .backgroundImage(image: sheetDraft.hasThemeDraft.thumbnail, imageName: sheetDraft.hasThemeDraft.imagePathThumbnail)
        ]
        let sheetCellsTransBackground: [NewOrEditIphoneController.Cell] = [
            .asTheme(themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }),
            .backgroundColor(sheetDraft.hasThemeDraft.sheetBackgroundColor),
            .backgroundImage(image: sheetDraft.hasThemeDraft.thumbnail, imageName: sheetDraft.hasThemeDraft.imagePathThumbnail),
            .backgroundTransparancy(sheetDraft.hasThemeDraft.backgroundTransparancy)
        ]
        return sheetDraft.hasAnyImage() ? sheetCellsTransBackground : sheetCells
    }
    private var titleRows: [NewOrEditIphoneController.Cell] {
        [
            .titleFontFamily(sheetDraft.hasThemeDraft.titleFontName ?? "Avenir"),
            .titleFontSize(sheetDraft.hasThemeDraft.titleTextSize),
            .titleBorderSize(sheetDraft.hasThemeDraft.titleBorderSize),
            .titleTextColor(sheetDraft.hasThemeDraft.textColorTitle),
            .titleBorderColor(sheetDraft.hasThemeDraft.borderColorTitle),
            .titleBold(sheetDraft.hasThemeDraft.isTitleBold),
            .titleItalic(sheetDraft.hasThemeDraft.isTitleItalic),
            .titleUnderlined(sheetDraft.hasThemeDraft.isTitleUnderlined)
        ]
    }
    private var lyricsRows: [NewOrEditIphoneController.Cell] {
        [
            .lyricsFontFamily(sheetDraft.hasThemeDraft.contentFontName ?? "Avenir"),
            .lyricsFontSize(sheetDraft.hasThemeDraft.contentTextSize),
            .lyricsBorderSize(sheetDraft.hasThemeDraft.contentBorderSize),
            .lyricsTextColor(sheetDraft.hasThemeDraft.textColorLyrics),
            .lyricsBorderColor(sheetDraft.hasThemeDraft.borderColorLyrics),
            .lyricsBold(sheetDraft.hasThemeDraft.isContentBold),
            .lyricsItalic(sheetDraft.hasThemeDraft.isContentItalic),
            .lyricsUnderlined(sheetDraft.hasThemeDraft.isContentUnderlined)
        ]
    }
    
    private var sheetDraft: SheetDraft {
        mode.sheetDraft
    }
    
    init(mode: Mode) {
        self.mode = mode
    }
    
    func getSheet() -> SheetType {
        sheetDraft.sheetType
    }
    
    func setDelegate(_ delegate: CreateEditThemeViewModelDelegate) {
        self.delegate = delegate
    }
    
    func getSections() -> [NewOrEditIphoneController.Section] {
        return sections
    }
    
    func getRowsFor(section: NewOrEditIphoneController.Section) -> [NewOrEditIphoneController.Cell] {
        switch section {
        case .input: return inputRows
        case .general: return generalRows
        case .title: return titleRows
        case .content: return lyricsRows
        case .image: return []
        }
    }
    
    func handle(cell: NewOrEditIphoneController.Cell) {
        sheetDraft.update(cell)
        try? sheetDraft.hasThemeDraft.update(cell)
        delegate?.draftDidUpdate(cell: cell)
    }
    
    func updateDraftAs(theme: ThemeCodable) {
    }
    
}
