//
//  LabelSwitchCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class LabelSwitchCell: ChurchBeamCell, TagImplementation, SheetImplementation {
	
	
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var `switch`: UISwitch!
	
	
	var id = ""
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var sheet: Sheet?
	var sheetAttribute: SheetAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	
	var switchThumbNailColor: UIColor {
		return self.switch.isOn ? isThemeLight ? .white : .black : isThemeLight ? .white : UIColor(hex: "FF8324")!
	}
	var switchBackgroundColor: UIColor {
		return self.switch.isOn ? isThemeLight ? .blue : UIColor(hex: "FF8324")! : isThemeLight ? .white : .darkGray
	}

	static let identifier = "LabelSwitchCell"
	
	override func awakeFromNib() {
		self.switch.isOn = false
		self.switch.thumbTintColor = switchThumbNailColor
		self.switch.onTintColor = switchBackgroundColor
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
	
	func apply(sheet: Sheet, sheetAttribute: SheetAttribute) {
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
		applyCellValueToTag()
		valueChanged(self.switch)
	}
	
	func applyCellValueToTag() {
		if let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .allHaveTitle: sheetTheme?.allHaveTitle = self.switch.isOn
			case .displayTime: sheetTheme?.displayTime = self.switch.isOn
			case .hasEmptySheet: sheetTheme?.hasEmptySheet = self.switch.isOn
			case .isEmptySheetFirst: sheetTheme?.isEmptySheetFirst = self.switch.isOn
			case .isLyricsBold: sheetTheme?.isLyricsBold = self.switch.isOn
			case .isLyricsItalian: sheetTheme?.isLyricsItalian = self.switch.isOn
			case .isLyricsUnderlined: sheetTheme?.isLyricsUnderlined = self.switch.isOn
			case .isTitleBold: sheetTheme?.isTitleBold = self.switch.isOn
			case .isTitleItalian: sheetTheme?.isTitleItalian = self.switch.isOn
			case .isTitleUnderlined: sheetTheme?.isTitleUnderlined = self.switch.isOn
			default:
				return
			}
		}
		if let sheetAttribute = sheetAttribute {
			switch sheetAttribute {
			case .SheetImageHasBorder: (sheet as! SheetTitleImageEntity).imageHasBorder = self.switch.isOn
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
			case .isLyricsBold: self.switch.isOn = sheetTheme?.isLyricsBold ?? false
			case .isLyricsItalian: self.switch.isOn = sheetTheme?.isLyricsItalian ?? false
			case .isLyricsUnderlined: self.switch.isOn = sheetTheme?.isLyricsUnderlined ?? false
			case .isTitleBold:  self.switch.isOn = sheetTheme?.isTitleBold ?? false
			case .isTitleItalian: self.switch.isOn = sheetTheme?.isTitleItalian ?? false
			case .isTitleUnderlined: self.switch.isOn = sheetTheme?.isTitleUnderlined ?? false
			default: return
			}
		}
		if let sheetAttribute = sheetAttribute {
			switch sheetAttribute {
			case .SheetImageHasBorder: self.switch.isOn = (sheet as! SheetTitleImageEntity).imageHasBorder
			default: break
			}
		}
		self.switch.thumbTintColor = switchThumbNailColor
		self.switch.onTintColor = switchBackgroundColor
	}
	
	@IBAction func valueChanged(_ sender: UISwitch) {
		self.switch.thumbTintColor = switchThumbNailColor
		self.switch.onTintColor = switchBackgroundColor
		applyCellValueToTag()
		valueDidChange?(self)
	}
	
	
}
