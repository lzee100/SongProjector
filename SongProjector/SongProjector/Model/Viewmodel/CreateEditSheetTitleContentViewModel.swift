//
//  CreateEditSheetTitleContentViewModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

protocol CreateEditSheetViewModelProtocol: CreateEditThemeSheetViewModelProtocol {
    var sheetDraft: SheetDraft { get }
}


class CreateEditSheetTitleContentViewModel: CreateEditSheetViewModelProtocol {
    
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
    var sheetDraft: SheetDraft {
        mode.sheetDraft
    }
    var themeDraft: ThemeDraft {
        mode.sheetDraft.hasThemeDraft
    }
    
    private weak var delegate: CreateEditThemeViewModelDelegate?
    private let mode: Mode
    private let sections: [NewOrEditIphoneController.Section] = [.input, .general, .title, .content]
    
    private var inputRows: [NewOrEditIphoneController.Cell] {
        [
            .title(sheetDraft.title ?? AppText.NewTheme.sampleTitle),
            .content(sheetDraft.content ?? AppText.NewTheme.sampleLyrics)
        ]
    }
    private var generalRows: [NewOrEditIphoneController.Cell] {
        let themes: [Theme] = DataFetcher().getEntities(moc: moc)

        let sheetCells: [NewOrEditIphoneController.Cell] = [
            .asTheme(themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }),
            .backgroundColor(sheetDraft.hasThemeDraft.sheetBackgroundColor),
            .backgroundImage(image: sheetDraft.hasThemeDraft.backgroundImage, imageName: sheetDraft.hasThemeDraft.imagePath)
        ]
        let sheetCellsTransBackground: [NewOrEditIphoneController.Cell] = [
            .asTheme(themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }),
            .backgroundColor(sheetDraft.hasThemeDraft.sheetBackgroundColor),
            .backgroundImage(image: sheetDraft.hasThemeDraft.backgroundImage, imageName: sheetDraft.hasThemeDraft.imagePath),
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
        case .content: return []
        case .image: return []
        }
    }
    
    func handle(cell: NewOrEditIphoneController.Cell) {
        sheetDraft.update(cell)
        try? sheetDraft.hasThemeDraft.update(cell)
        delegate?.draftDidUpdate(cell: cell)
    }
}
