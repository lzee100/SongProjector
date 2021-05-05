//
//  LabelColorPickerNewCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import FlexColorPicker


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
    
    @IBAction func didPressDelete(_ sender: ActionButton) {
        setNewColor(nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        colorPreviewView.layer.borderColor = UIColor.blackColor.cgColor
    }
    
}

extension LabelColorPickerNewCell: ColorPickerDelegate {
    
    func colorPicker(_ colorPicker: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
    }
    
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
    }
    
}
