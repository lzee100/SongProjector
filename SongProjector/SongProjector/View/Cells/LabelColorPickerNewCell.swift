//
//  LabelColorPickerNewCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit


class LabelColorPickerNewCell: ChurchBeamCell, ThemeImplementation {
    
    @IBOutlet var descriptionTitle: UILabel!
    @IBOutlet var colorPreviewView: UIView!
    @IBOutlet var deleteButton: ActionButton!
    
    @IBOutlet var deleteButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet var deleteButtonWidthConstraint: NSLayoutConstraint!
    var id = ""
    var sheetTheme: VTheme?
    var themeAttribute: ThemeAttribute?
    var valueDidChange: ((ChurchBeamCell) -> Void)?
    var selectedColor: UIColor? {
        didSet {
            deleteButtonWidthConstraint.constant = selectedColor == nil ? 0 : 40
            deleteButtonRightConstraint.constant = selectedColor == nil ? 30 : 20
        }
    }
    
    private var delegate: CreateEditThemeSheetCellDelegate?
    private var cell: NewOrEditIphoneController.Cell?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorPreviewView.layer.cornerRadius = colorPreviewView.bounds.height / 2
    }
    
    static let identifier = "LabelColorPickerNewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorPreviewView.layer.borderColor = UIColor.blackColor.cgColor
        colorPreviewView.layer.borderWidth = 1
        deleteButton.tintColor = .red2
    }
    
    static func create(id: String, description: String) -> LabelColorPickerNewCell {
        let view : LabelColorPickerNewCell! = UIView.create(nib: "LabelColorPickerCell")
        view.id = id
        view.descriptionTitle.text = description
        return view
    }
    
    func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
        self.sheetTheme = theme
        self.themeAttribute = themeAttribute
        self.descriptionTitle.text = themeAttribute.description
        applyValueToCell()
    }
    
    func applyValueToCell() {
        var color: UIColor? = nil
        if let themeAttribute = themeAttribute {
            switch themeAttribute {
            case .backgroundColor:
                if let colorHex = sheetTheme?.backgroundColor {
                    color = UIColor(hex: colorHex)
                }
            case .titleTextColorHex:
                if let colorHex = sheetTheme?.titleTextColorHex {
                    color = UIColor(hex: colorHex)
                }
            case .titleBackgroundColor:
                if let colorHex = sheetTheme?.titleBackgroundColor {
                    color = UIColor(hex: colorHex)
                }
            case .titleBorderColorHex:
                if let colorHex = sheetTheme?.titleBorderColorHex {
                    color = UIColor(hex: colorHex)
                }
            case .contentTextColorHex:
                if let colorHex = sheetTheme?.contentTextColorHex {
                    color = UIColor(hex: colorHex)
                }
            case .contentBorderColor:
                if let colorHex = sheetTheme?.contentBorderColorHex {
                    color = UIColor(hex: colorHex)
                }
            default: return
            }
        }
        set(value: color)
    }
    
    func applyCellValueToTheme() {
        if let themeAttribute = themeAttribute {
            let color = selectedColor?.hexCode
            switch themeAttribute {
            case .backgroundColor:
                sheetTheme?.backgroundColor = color
                if sheetTheme?.backgroundTransparancy == 0 {
                    sheetTheme?.backgroundTransparancy = 100
                }
            case .titleTextColorHex: sheetTheme?.titleTextColorHex = color
            case .titleBorderColorHex: sheetTheme?.titleBorderColorHex = color
            case .contentTextColorHex: sheetTheme?.contentTextColorHex = color
            case .contentBorderColor: sheetTheme?.contentBorderColorHex = color
            case .titleBackgroundColor: sheetTheme?.titleBackgroundColor = color
            default: return
            }
        }
    }
    
    func set(value: Any?) {
        if value == nil {
            selectedColor = nil
            colorPreviewView.backgroundColor = selectedColor
            applyCellValueToTheme()
        }
        if let value = value as? UIColor {
            selectedColor = value
            colorPreviewView.backgroundColor = selectedColor
            applyCellValueToTheme()
        }
    }
    
    func setNewColor(_ color: UIColor?) {
        self.selectedColor = color
        applyCellValueToTheme()
        applyValueToCell()
        colorPreviewView.backgroundColor = color
        valueDidChange?(self)
    }
    
    fileprivate func updateColor(applyToCell: Bool, cell: NewOrEditIphoneController.Cell, newColor: UIColor?) {
        switch cell {
        case .titleTextColor(let color):
            applyToCell ? set(value: color) : delegate?.handle(cell: .titleTextColor(newColor))
        case .titleBorderColor(let color):
            applyToCell ? set(value: color) : delegate?.handle(cell: .titleBorderColor(newColor))
        case .titleBackgroundColor(let color):
            applyToCell ? set(value: color) : delegate?.handle(cell: .titleBackgroundColor(newColor))
        case .backgroundColor(let color):
            applyToCell ? set(value: color) : delegate?.handle(cell: .backgroundColor(newColor))
        case .lyricsTextColor(let color):
            applyToCell ? set(value: color) : delegate?.handle(cell: .lyricsTextColor(newColor))
        case .lyricsBorderColor(let color):
            applyToCell ? set(value: color) : delegate?.handle(cell: .lyricsBorderColor(newColor))
        case .imageBorderColor(let color):
            applyToCell ? set(value: color) : delegate?.handle(cell: .imageBorderColor(newColor))
        default: break
        }

    }
    
    @IBAction func didPressDelete(_ sender: ActionButton) {
        setNewColor(nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        colorPreviewView.layer.borderColor = UIColor.blackColor.cgColor
    }
    
}

extension LabelColorPickerNewCell: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        guard let cell = cell else {
            return
        }
        set(value: color)
        updateColor(applyToCell: false, cell: cell, newColor: color)
    }
    
}

extension LabelColorPickerNewCell: CreateEditThemeSheetCellProtocol {
    
    func configure(cell: NewOrEditIphoneController.Cell, delegate: CreateEditThemeSheetCellDelegate) {
        self.cell = cell
        self.delegate = delegate
        descriptionTitle.text = cell.description
        updateColor(applyToCell: true, cell: cell, newColor: nil)
    }

}
