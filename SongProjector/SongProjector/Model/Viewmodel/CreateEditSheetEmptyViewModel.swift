//
//  CreateEditSheetEmptyViewModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

class CreateEditSheetEmptyViewModel: CreateEditThemeSheetViewModelProtocol {    
    
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
    private let sections: [NewOrEditIphoneController.Section]  = [.input, .general]
    
    private var inputRows: [NewOrEditIphoneController.Cell] {
        [
            .title(sheetDraft.title ?? AppText.NewTheme.sampleTitle)
        ]
    }
    private var generalRows: [NewOrEditIphoneController.Cell] {
        let themes: [Theme] = DataFetcher().getEntities(moc: moc)

        let sheetCells: [NewOrEditIphoneController.Cell] = [
            .asTheme(themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }),
            .backgroundColor(sheetDraft.hasThemeDraft.sheetBackgroundColor),
            .backgroundImage(sheetDraft.hasThemeDraft.thumbnail)
        ]
        let sheetCellsTransBackground: [NewOrEditIphoneController.Cell] = [
            .asTheme(themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }),
            .backgroundColor(sheetDraft.hasThemeDraft.sheetBackgroundColor),
            .backgroundImage(sheetDraft.hasThemeDraft.thumbnail),
            .backgroundTransparancy(sheetDraft.hasThemeDraft.backgroundTransparancy)
        ]
        return sheetDraft.hasAnyImage() ? sheetCellsTransBackground : sheetCells
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
        case .title: return []
        case .content: return []
        case .image: return []
        }
    }
    
    func handle(cell: NewOrEditIphoneController.Cell) {
        sheetDraft.update(cell)
        sheetDraft.hasThemeDraft.update(cell)
        delegate?.draftDidUpdate(cell: cell)
    }
    
    func updateDraftAs(theme: ThemeCodable) {
    }
    
}
