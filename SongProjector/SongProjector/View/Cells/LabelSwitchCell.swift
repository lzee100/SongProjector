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
	var sheetTag: Tag?
	var tagAttribute: TagAttribute?
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
	
	func apply(tag: Tag, tagAttribute: TagAttribute) {
		sheetTag = tag
		self.tagAttribute = tagAttribute
		descriptionLabel.text = tagAttribute.description
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
		if let tagAttribute = tagAttribute {
			switch tagAttribute {
			case .allHaveTitle: sheetTag?.allHaveTitle = self.switch.isOn
			case .displayTime: sheetTag?.displayTime = self.switch.isOn
			case .hasEmptySheet: sheetTag?.hasEmptySheet = self.switch.isOn
			case .isEmptySheetFirst: sheetTag?.isEmptySheetFirst = self.switch.isOn
			case .isContentBold: sheetTag?.isContentBold = self.switch.isOn
			case .isContentItalic: sheetTag?.isContentItalic = self.switch.isOn
			case .isContentUnderlined: sheetTag?.isContentUnderlined = self.switch.isOn
			case .isTitleBold: sheetTag?.isTitleBold = self.switch.isOn
			case .isTitleItalic: sheetTag?.isTitleItalic = self.switch.isOn
			case .isTitleUnderlined: sheetTag?.isTitleUnderlined = self.switch.isOn
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
		if let tagAttribute = tagAttribute {
			switch tagAttribute {
			case .allHaveTitle: self.switch.isOn = sheetTag?.allHaveTitle ?? false
			case .displayTime: self.switch.isOn = sheetTag?.displayTime ?? false
			case .hasEmptySheet: self.switch.setOn(sheetTag?.hasEmptySheet ?? false, animated: true)
			case .isEmptySheetFirst: self.switch.isOn = sheetTag?.isEmptySheetFirst ?? false
			case .isContentBold: self.switch.isOn = sheetTag?.isContentBold ?? false
			case .isContentItalic: self.switch.isOn = sheetTag?.isContentItalic ?? false
			case .isContentUnderlined: self.switch.isOn = sheetTag?.isContentUnderlined ?? false
			case .isTitleBold:  self.switch.isOn = sheetTag?.isTitleBold ?? false
			case .isTitleItalic: self.switch.isOn = sheetTag?.isTitleItalic ?? false
			case .isTitleUnderlined: self.switch.isOn = sheetTag?.isTitleUnderlined ?? false
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
