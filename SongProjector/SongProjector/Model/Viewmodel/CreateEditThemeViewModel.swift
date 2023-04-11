//
//  NewOrEditThemeViewModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

protocol CreateEditThemeSheetViewModelProtocol: CreateEditThemeSheetCellDelegate {
    var displayTime: Bool { get }
    func setDelegate(_ delegate: CreateEditThemeViewModelDelegate)
    func getSections() -> [NewOrEditIphoneController.Section]
    func getRowsFor(section: NewOrEditIphoneController.Section) -> [NewOrEditIphoneController.Cell]
}

protocol CreateEditThemeViewModelProtocol: CreateEditThemeSheetViewModelProtocol {
    var sheet: SheetTitleContentCodable { get }
    var hasEmptySheet: Bool { get }
    var hasEmptySheetBeginningIndex: Int { get }
    var themeDraft: ThemeDraft { get }
    func updateDraftAs(theme: ThemeCodable)
}


protocol CreateEditThemeViewModelDelegate: AnyObject {
    func draftDidUpdate(cell: NewOrEditIphoneController.Cell)
}

class CreateEditThemeViewModel: CreateEditThemeViewModelProtocol {
    
    enum Mode {
        case new(ThemeDraft)
        case edit(ThemeDraft)
        
        var themeDraft: ThemeDraft {
            switch self {
            case .new(let themeDraft): return themeDraft
            case .edit(let themeDraft): return themeDraft
            }
        }
    }
    
    var displayTime: Bool {
        mode.themeDraft.displayTime
    }
    var hasEmptySheet: Bool {
        return mode.themeDraft.hasEmptySheet
    }
    var hasEmptySheetBeginningIndex: Int {
        return 2
    }
    var themeDraft: ThemeDraft {
        mode.themeDraft
    }
    let sheet: SheetTitleContentCodable
    weak var delegate: CreateEditThemeViewModelDelegate?
    
    let mode: Mode
    private let sections: [NewOrEditIphoneController.Section] = [.input, .general, .title, .content]
    private var inputRows: [NewOrEditIphoneController.Cell] {
        [.title(themeDraft.title ?? AppText.NewTheme.sampleTitle)]
    }
    private var generalRows: [NewOrEditIphoneController.Cell] {
        let themes: [Theme] = DataFetcher().getEntities(moc: moc)
        var cells: [NewOrEditIphoneController.Cell] = [.asTheme(themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }), .hasEmptySheet(themeDraft.hasEmptySheet)]
        if themeDraft.hasEmptySheet {
            cells.append(.hasEmptySheetBeginning(themeDraft.isEmptySheetFirst))
        }
        cells.append(contentsOf: [.allHaveTitle(themeDraft.allHaveTitle), .backgroundColor(UIColor(hex: themeDraft.backgroundColor)), .backgroundImage(image: themeDraft.imageSelectionAction.image ?? themeDraft.thumbnail, imageName: themeDraft.imageSelectionAction.image != nil ? nil : themeDraft.imagePathThumbnail)])
        if themeDraft.hasAnyImage() {
            cells.append(.backgroundTransparancy(themeDraft.backgroundTransparancy))
        }
        cells.append(.displayTime(themeDraft.displayTime))
        return cells
    }
    private var titleRows: [NewOrEditIphoneController.Cell] {
        [
            .titleFontFamily(themeDraft.titleFontName ?? "Avenir"),
            .titleFontSize(themeDraft.titleTextSize),
            .titleBorderSize(themeDraft.titleBorderSize),
            .titleTextColor(themeDraft.textColorTitle),
            .titleBorderColor(themeDraft.borderColorTitle),
            .titleBold(themeDraft.isTitleBold),
            .titleItalic(themeDraft.isTitleItalic),
            .titleUnderlined(themeDraft.isTitleUnderlined)
        ]
    }
    private var lyricsRows: [NewOrEditIphoneController.Cell] {
        [
            .lyricsFontFamily(themeDraft.contentFontName ?? "Avenir"),
            .lyricsFontSize(themeDraft.contentTextSize),
            .lyricsBorderSize(themeDraft.contentBorderSize),
            .lyricsTextColor(themeDraft.textColorLyrics),
            .lyricsBorderColor(themeDraft.borderColorLyrics),
            .lyricsBold(themeDraft.isContentBold),
            .lyricsItalic(themeDraft.isContentItalic),
            .lyricsUnderlined(themeDraft.isContentUnderlined)
        ]
    }

    init(mode: Mode, sheet: SheetTitleContentCodable) {
        self.mode = mode
        self.sheet = sheet
    }
    
    func getSheet() -> SheetType {
        .SheetTitleContent
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
        try? themeDraft.update(cell)
        delegate?.draftDidUpdate(cell: cell)
    }
    
    func updateDraftAs(theme: ThemeCodable) {
        themeDraft.updateFrom(theme)
    }
    
}
