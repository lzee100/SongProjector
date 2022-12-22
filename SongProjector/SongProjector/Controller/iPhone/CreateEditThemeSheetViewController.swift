//
//  NewOrEditThemeIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

protocol CreateEditThemeSheetCellProtocol {
    func configure(cell: NewOrEditIphoneController.Cell, delegate: CreateEditThemeSheetCellDelegate)
}

protocol CreateEditThemeSheetCellDelegate {
    func handle(cell: NewOrEditIphoneController.Cell, value: CreateEditThemeSheetViewController.CreateEditThemeSheetCellUpdateValue)
}

class CreateEditThemeSheetViewController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, CreateEditThemeViewModelDelegate {
    
    enum CreateEditThemeSheetCellUpdateValue {
        case theme(ThemeDraft.UpdateProperties)
        case sheet(SheetDraft.UpdateProperties)
    }
    
    enum NewOrEditThemeAndSheetMode {
        case theme(CreateEditThemeSheetViewModelProtocol)
        case sheet(CreateEditThemeSheetViewModelProtocol)
        
        var createEditThemeSheetViewModelProtocol: CreateEditThemeSheetViewModelProtocol {
            switch self {
            case .theme(let viewModelProtocol): return viewModelProtocol
            case .sheet(let viewModelProtocol): return viewModelProtocol
            }
        }
    }
    
    private lazy var cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPressCancelDraft))
    private lazy var save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didPressSaveDraft))
    private let previewView = UIView()
    private let tableView = UITableView()
    private lazy var previewViewRatioConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: previewView, attribute: .height, relatedBy: .equal, toItem: previewView, attribute: .width, multiplier: externalDisplayWindowRatioHeightWidth, constant: 0.0)
    }()
    private let mode: NewOrEditThemeAndSheetMode
    private var activeIndexPath: IndexPath?

    init(mode: NewOrEditThemeAndSheetMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        mode.createEditThemeSheetViewModelProtocol.getSections().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = mode.createEditThemeSheetViewModelProtocol.getSections()[section]
        return mode.createEditThemeSheetViewModelProtocol.getRowsFor(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = mode.createEditThemeSheetViewModelProtocol.getSections()[indexPath.section]
        let cellType = mode.createEditThemeSheetViewModelProtocol.getRowsFor(section: section)[indexPath.row]
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellType.cellIdentifier)
        (cell as? CreateEditThemeSheetCellProtocol)?.configure(cell: cellType, delegate: mode.createEditThemeSheetViewModelProtocol)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = self.tableView(tableView, cellForRowAt: indexPath) as? DynamicHeightCell {
            return cell.preferredHeight
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.basicHeaderView else { return nil }
        switch mode.createEditThemeSheetViewModelProtocol.getSections()[section] {
        case .input:
            view.descriptionLabel.text = AppText.NewTheme.sectionInput
        case .general:
            view.descriptionLabel.text = AppText.NewTheme.sectionGeneral
        case .title:
            view.descriptionLabel.text = AppText.NewTheme.sectionTitle
        case .content:
            view.descriptionLabel.text = AppText.NewTheme.sectionLyrics
        case .image:
            view.descriptionLabel.text = AppText.NewSheetTitleImage.title
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeIndexPath = activeIndexPath == indexPath ? nil : indexPath
        if let cell = tableView.cellForRow(at: indexPath), cell is DynamicHeightCell {
            if activeIndexPath != nil {
                self.reloadDataWithScrollTo(cell)
            } else {
                tableView.reloadData()
            }
        }
        if let cell = tableView.cellForRow(at: indexPath) as? LabelColorPickerNewCell {
            let colorPickerController = UIColorPickerViewController()
            colorPickerController.selectedColor = cell.selectedColor ?? .whiteColor
            cell.tag = 1
            colorPickerController.delegate = self
            self.present(colorPickerController, animated: true)
        }
    }
    
    // MARK: CreateEditThemeViewModelDelegate functions
    
    func draftDidUpdate(cell: NewOrEditIphoneController.Cell) {
        var needsReload: Bool = false
        switch cell {
        case .backgroundTransparancy: updateTransparency()
        case .title, .titleBorderSize, .titleFontFamily, .titleFontSize, .titleAlignment, .titleTextColor, .titleBorderColor, .titleBold, .titleItalic, .titleUnderlined: updateSheetTitle()
            case .lyricsFontFamily, .lyricsFontSize, .lyricsTextColor, .lyricsAlignment, .lyricsBorderColor, .lyricsBorderSize, .lyricsBold, .lyricsItalic, .lyricsUnderlined: updateSheetContent()
            case .displayTime: updateTime()
            case .backgroundImage:
                updateBackgroundImage()
                needsReload = true
        case .image, .imageBorderSize, .imageBorderColor, .pastorImage:
            updateSheetImage()
            switch cell {
            case .image: needsReload = true
            case .pastorImage: needsReload = true
            default: break
            }
            case .backgroundColor, .titleBackgroundColor:
                updateBackgroundColor()
                updateTransparency()
            case .asTheme:
                buildPreview()
                needsReload = true
        case .hasEmptySheet:
            if let viewModel = mode.createEditThemeSheetViewModelProtocol as? CreateEditThemeViewModelProtocol {
                if viewModel.hasEmptySheet {
                    tableView.insertRows(at: [IndexPath(row: viewModel.hasEmptySheetBeginningIndex, section: 1)], with: .top)
                } else {
                    tableView.deleteRows(at: [IndexPath(row: viewModel.hasEmptySheetBeginningIndex, section: 1)], with: .top)
                }
            }
        default: break
            }
        
        if cell.updateDynamicHeigts, !needsReload {
            activeIndexPath = nil
        }
        
        if needsReload {
            tableView.reloadData()
        }
        

    }
    
    private func setup() {
        
        self.view.addSubview(previewView)
        self.view.addSubview(tableView)
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = HeaderView.height
        tableView.sectionHeaderHeight = HeaderView.height
        cancel.title = AppText.Actions.cancel
        save.title = AppText.Actions.save
        cancel.tintColor = themeHighlighted
        save.tintColor = themeHighlighted
        previewViewRatioConstraint.isActive = true
        mode.createEditThemeSheetViewModelProtocol.setDelegate(self)
        
        tableView.backgroundColor = .clear
        NotificationCenter.default.addObserver(forName: .externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
        
        tableView.register(header: BasicHeaderView.identifier)
        tableView.register(cell: Cells.labelNumberCell)
        tableView.register(cell: LabelColorPickerNewCell.identifier)
        tableView.register(cell: Cells.LabelPickerCell)
        tableView.register(cell: Cells.LabelSwitchCell)
        tableView.register(cell: Cells.labelTextFieldCell)
        tableView.register(cell: Cells.LabelPhotoPickerCell)
        tableView.register(cell: LabelTextViewCell.identifier)
        tableView.register(cell: LabelSliderCell.identifier)
        tableView.register(cell: LabelDoubleSwitchCell.identifier)
        
        refineSheetRatio()
        
        cancel.title = AppText.Actions.cancel
        save.title = AppText.Actions.save
        cancel.tintColor = themeHighlighted
        save.tintColor = themeHighlighted
        
        hideKeyboardWhenTappedAround()
        
        tableView.keyboardDismissMode = .interactive
        
        buildPreview()
    }

    private func reloadDataWithScrollTo(_ cell: UITableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    private func buildPreview() {
        
        for subview in previewView.subviews {
            subview.removeFromSuperview()
        }
        
        if let sheetModel = mode.createEditThemeSheetViewModelProtocol as? CreateEditSheetViewModelProtocol {
            let sheetCodable = sheetModel.sheetDraft.makeCodable()
            let sheetViewSheet: SheetView.SheetCodable?
            switch sheetCodable {
            case .sheetTitleContent(let sheet): sheetViewSheet = .sheetTitleContentCodable(sheet)
            case .sheetTitleImage(let sheet): sheetViewSheet = .sheetTitleImageCodable(sheet)
            case .sheetEmpty(let sheet): sheetViewSheet = .sheetEmptyCodable(sheet)
            case .sheetSplit(let sheet): sheetViewSheet = .sheetSplitCodable(sheet)
            case .sheetPastors(let sheet): sheetViewSheet = .sheetPastorsCodable(sheet)
            case .none: sheetViewSheet = .none
            }
            let theme = sheetCodable.themeCodable
            if let sheetViewSheet = sheetViewSheet {
                previewView.addSubview(SheetView.createWith(frame: previewView.bounds, cluster: nil, sheet: sheetViewSheet, theme: theme, scaleFactor: getScaleFactor(width: previewView.bounds.width), toExternalDisplay: true))
            }
        } else if let themeModel = mode.createEditThemeSheetViewModelProtocol as? CreateEditThemeViewModelProtocol {
            let sheet = themeModel.sheet
            let theme = themeModel.themeDraft.themeCodable
            previewView.addSubview(SheetView.createWith(frame: previewView.bounds, cluster: nil, sheet: .sheetTitleContentCodable(sheet), theme: theme, scaleFactor: getScaleFactor(width: previewView.bounds.width), toExternalDisplay: true))
        }
    }
    
    private func updateTransparency() {
        if let view = previewView.subviews.first {
            
            if let sheet = view as? SheetView {
                sheet.updateOpacity()
            }
            if let view = externalDisplayWindow?.subviews.first as? SheetView {
                view.updateOpacity()
            }
        }
    }
    
    private func updateSheetTitle() {
        if let view = previewView.subviews.first as? SheetView {
            view.updateTitle()
        }
        if let view = externalDisplayWindow?.subviews.first as? SheetView {
            view.updateTitle()
        }
    }
    
    private func updateSheetContent() {
        if let view = previewView.subviews.first as? SheetView {
            view.updateContent()
        }
        if let view = externalDisplayWindow?.subviews.first as? SheetView {
            view.updateContent()
        }
    }
        
    private func updateBackgroundImage() {
        if let view = previewView.subviews.first as? SheetView {
            view.updateBackgroundImage()
        }
        if let view = externalDisplayWindow?.subviews.first as? SheetView {
            view.updateBackgroundImage()
        }
    }
    
    private func updateSheetImage() {
        if let view = previewView.subviews.first, let sheet = view as? SheetView {
            sheet.updateSheetImage()
        }
        if let view = externalDisplayWindow?.subviews.first as? SheetView {
            view.updateSheetImage()
        }
    }
    
    private func updateBackgroundColor() {
        if let view = previewView.subviews.first as? SheetView {
            view.updateBackgroundColor()
        }
        if let view = externalDisplayWindow?.subviews.first as? SheetView {
            view.updateBackgroundColor()
        }
    }
    
    private func updateTime() {
        if let view = previewView.subviews.first, let sheet = view as? SheetView, let viewModel = mode.createEditThemeSheetViewModelProtocol as? CreateEditThemeViewModelProtocol {
            sheet.updateTime(isOn: viewModel.displayTime)
        }
        if let view = externalDisplayWindow?.subviews.first as? SheetView, let viewModel = mode.createEditThemeSheetViewModelProtocol as? CreateEditThemeViewModelProtocol {
            view.updateTime(isOn: viewModel.displayTime)
        }
    }

    @objc func externalDisplayDidChange(_ notification: Notification) {
        refineSheetRatio()
    }
    
    private func set(image: UIImage?, for sheet: VSheet) {
        if let sheet = sheet as? VSheetPastors {
            do {
                try sheet.set(image: image, imageName: nil)
            } catch {
                show(message: error.localizedDescription)
            }
        }
        if let sheet = sheet as? VSheetTitleImage {
            do {
                try sheet.set(image: image, imageName: nil)
            } catch {
                show(message: error.localizedDescription)
            }
        }
    }
    
    private func refineSheetRatio() {
        // deactivate standard constraint
        previewViewRatioConstraint.isActive = false
        
        // remove previous constraint
        previewView.removeConstraint(previewViewRatioConstraint)
        
        // add new constraint
        previewViewRatioConstraint = NSLayoutConstraint(item: previewView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: previewView, attribute: NSLayoutConstraint.Attribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
        previewView.addConstraint(previewViewRatioConstraint)
        
        previewView.layoutIfNeeded()
        buildPreview()
    }
    
    @objc func didPressCancelDraft() {
        
    }
    
    @objc func didPressSaveDraft() {
        
    }


}

extension CreateEditThemeSheetViewController: UIColorPickerViewControllerDelegate {
    
}
