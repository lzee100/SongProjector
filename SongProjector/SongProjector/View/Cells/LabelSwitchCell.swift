//
//  LabelSwitchCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class LabelSwitchCell: ChurchBeamCell, ThemeImplementation, SheetImplementation {
	
	
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var `switch`: UISwitch!
	
	
	var id = ""
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var sheet: VSheet?
	var sheetAttribute: SheetAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
    
	static let identifier = "LabelSwitchCell"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.switch.thumbTintColor = .whiteColor
    }
	
	override func awakeFromNib() {
		self.switch.isOn = false
	}
	
	static func create(id: String, description: String, initialValueIsOn: Bool = false) -> LabelSwitchCell {
		let view : LabelSwitchCell! = UIView.create(nib: "LabelSwitchCell")
		view.id = id
		view.descriptionLabel.text = description
		view.switch.isOn = initialValueIsOn
		return view
	}
	
	func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
		sheetTheme = theme
		self.themeAttribute = themeAttribute
		descriptionLabel.text = themeAttribute.description
		applyValueToCell()
	}
	
	func apply(sheet: VSheet, sheetAttribute: SheetAttribute) {
		self.sheet = sheet
		self.sheetAttribute = sheetAttribute
		descriptionLabel.text = sheetAttribute.description
		applyValueToCell()
	}
	
	func set(value: Any?) {
		guard value != nil else {
			setSwitchValueTo(value: false)
			return
		}
		if let value = value as? Bool {
			setSwitchValueTo(value: value)
		}
	}
	
	func setSwitchValueTo(value: Bool) {
		self.switch.isOn = value
		applyCellValueToTheme()
		valueChanged(self.switch)
	}
	
	func applyCellValueToTheme() {
		if let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .allHaveTitle: sheetTheme?.allHaveTitle = self.switch.isOn
			case .displayTime: sheetTheme?.displayTime = self.switch.isOn
			case .hasEmptySheet: sheetTheme?.hasEmptySheet = self.switch.isOn
			case .isEmptySheetFirst: sheetTheme?.isEmptySheetFirst = self.switch.isOn
			case .isContentBold: sheetTheme?.isContentBold = self.switch.isOn
			case .isContentItalic: sheetTheme?.isContentItalic = self.switch.isOn
			case .isContentUnderlined: sheetTheme?.isContentUnderlined = self.switch.isOn
			case .isTitleBold: sheetTheme?.isTitleBold = self.switch.isOn
			case .isTitleItalic: sheetTheme?.isTitleItalic = self.switch.isOn
			case .isTitleUnderlined: sheetTheme?.isTitleUnderlined = self.switch.isOn
			default:
				return
			}
		}
		if let sheetAttribute = sheetAttribute {
			switch sheetAttribute {
			case .SheetImageHasBorder: (sheet as! VSheetTitleImage).imageHasBorder = self.switch.isOn
			default: break
			}
		}
	}
	
	func applyValueToCell() {
		if let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .allHaveTitle: self.switch.isOn = sheetTheme?.allHaveTitle ?? false
			case .displayTime: self.switch.isOn = sheetTheme?.displayTime ?? false
			case .hasEmptySheet: self.switch.setOn(sheetTheme?.hasEmptySheet ?? false, animated: true)
			case .isEmptySheetFirst: self.switch.isOn = sheetTheme?.isEmptySheetFirst ?? false
			case .isContentBold: self.switch.isOn = sheetTheme?.isContentBold ?? false
			case .isContentItalic: self.switch.isOn = sheetTheme?.isContentItalic ?? false
			case .isContentUnderlined: self.switch.isOn = sheetTheme?.isContentUnderlined ?? false
			case .isTitleBold:  self.switch.isOn = sheetTheme?.isTitleBold ?? false
			case .isTitleItalic: self.switch.isOn = sheetTheme?.isTitleItalic ?? false
			case .isTitleUnderlined: self.switch.isOn = sheetTheme?.isTitleUnderlined ?? false
			default: return
			}
		}
		if let sheetAttribute = sheetAttribute {
			switch sheetAttribute {
			case .SheetImageHasBorder: self.switch.isOn = (sheet as! VSheetTitleImage).imageHasBorder
			default: break
			}
		}
//		self.switch.thumbTintColor = switchThumbNailColor
//		self.switch.onTintColor = switchBackgroundColor
	}
	
	@IBAction func valueChanged(_ sender: UISwitch) {
//		self.switch.thumbTintColor = switchThumbNailColor
//		self.switch.onTintColor = switchBackgroundColor
		applyCellValueToTheme()
		valueDidChange?(self)
	}
	
	
}
