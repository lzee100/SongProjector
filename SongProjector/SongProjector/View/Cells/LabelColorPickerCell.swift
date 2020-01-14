//
//  LabelColorPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol LabelColorPickerCellDelegate {
	func colorPickerDidChooseColor(cell: LabelColorPickerCell, colorPicker: ChromaColorPicker, color: UIColor?)
}

class LabelColorPickerCell: ChurchBeamCell, ThemeImplementation, DynamicHeightCell, ChromaColorPickerDelegate {
	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var colorPickerContainer: UIView!
	@IBOutlet var colorPreview: UIView!
	
	var delegate: LabelColorPickerCellDelegate?
	
	var preferredHeight : CGFloat {
		return isActive ? 360 : 60
	}
	
	var id = ""
	var isActive = false { didSet { toggle() } }
	var colorPicker = ChromaColorPicker()
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	var selectedColor: UIColor?
	
	static let identifier = "LabelColorPickerCell"
	
	override func awakeFromNib() {
		colorPreview.layer.borderColor = themeHighlighted.cgColor
		colorPreview.layer.borderWidth = 1.0
		colorPicker.backgroundColor = themeWhiteBlackBackground
		colorPickerContainer.isHidden = true
		colorPickerContainer.backgroundColor = themeWhiteBlackBackground
		
		
	}
	
	static func create(id: String, description: String) -> LabelColorPickerCell {
		let view : LabelColorPickerCell! = UIView.create(nib: "LabelColorPickerCell")
		view.id = id
		view.descriptionTitle.text = description
		return view
	}
	
	private func toggle() {
		if isActive {
			colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
			colorPicker.backgroundColor = themeWhiteBlackBackground
			colorPicker.delegate = self
			colorPicker.padding = 5
			colorPicker.stroke = 3
			colorPicker.hexLabel.textColor = UIColor.white
			colorPickerContainer.isHidden = false
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.colorPickerContainer.addSubview(self.colorPicker)
			})
		} else {
			colorPickerContainer.isHidden = true
			self.colorPicker.removeFromSuperview()
		}
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
			case .backgroundColor: sheetTheme?.backgroundColor = color
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
			colorPreview.backgroundColor = nil
			selectedColor = nil
			applyCellValueToTheme()
		}
		if let value = value as? UIColor {
			colorPreview.backgroundColor = value
			selectedColor = value
			applyCellValueToTheme()
		}
	}
	
	func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
		self.selectedColor = color
		applyCellValueToTheme()
		applyValueToCell()
		colorPreview.backgroundColor = color
		valueDidChange?(self)
	}
	
}
