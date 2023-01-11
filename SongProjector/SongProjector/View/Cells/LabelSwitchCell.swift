//
//  LabelSwitchCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class LabelSwitchCell: ChurchBeamCell, ThemeImplementation, SheetImplementation {
	
    static let identifier = "LabelSwitchCell"

	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var `switch`: UISwitch!
    
	var id = ""
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var sheet: VSheet?
	var sheetAttribute: SheetAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
        
    private var cell: NewOrEditIphoneController.Cell?
    private var newDelegate: CreateEditThemeSheetCellDelegate?
    
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
        switch cell {
        case .hasEmptySheet: newDelegate?.handle(cell: .hasEmptySheet(sender.isOn))
        case .hasEmptySheetBeginning: newDelegate?.handle(cell: .hasEmptySheetBeginning(sender.isOn))
        case .allHaveTitle: newDelegate?.handle(cell: .allHaveTitle(sender.isOn))
        case .displayTime: newDelegate?.handle(cell: .displayTime(sender.isOn))
        case .titleBold: newDelegate?.handle(cell: .titleBold(sender.isOn))
        case .titleItalic: newDelegate?.handle(cell: .titleItalic(sender.isOn))
        case .titleUnderlined: newDelegate?.handle(cell: .titleUnderlined(sender.isOn))
        case .lyricsBold: newDelegate?.handle(cell: .lyricsBold(sender.isOn))
        case .lyricsItalic: newDelegate?.handle(cell: .lyricsItalic(sender.isOn))
        case .lyricsUnderlined: newDelegate?.handle(cell: .lyricsUnderlined(sender.isOn))
        case .hasBorder: newDelegate?.handle(cell: .hasBorder(sender.isOn))
        default: break
        }
	}
}

extension LabelSwitchCell: CreateEditThemeSheetCellProtocol {
    
    func configure(cell: NewOrEditIphoneController.Cell, delegate: CreateEditThemeSheetCellDelegate) {
        self.cell = cell
        newDelegate = delegate
        descriptionLabel.text = cell.description
        switch cell {
        case .hasEmptySheet(let value): `switch`.isOn = value
        case .hasEmptySheetBeginning(let value): `switch`.isOn = value
        case .displayTime(let value): `switch`.isOn = value
        case .titleBold(let value): `switch`.isOn = value
        case .titleItalic(let value): `switch`.isOn = value
        case .titleUnderlined(let value): `switch`.isOn = value
        case .lyricsBold(let value): `switch`.isOn = value
        case .lyricsItalic(let value): `switch`.isOn = value
        case .lyricsUnderlined(let value): `switch`.isOn = value
        case .hasBorder(let value): `switch`.isOn = value
        default: break
        }
    }

}
