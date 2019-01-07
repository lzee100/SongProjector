//
//  LabelDoubleSwitchCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol LabelDoubleSwitchDelegate {
	func didSelectSwitch(first: Bool?, second: Bool?, cell: LabelDoubleSwitchCell)
}

class LabelDoubleSwitchCell: ChurchBeamCell, DynamicHeightCell, TagImplementation {
	
	@IBOutlet var descriptionSwitchOne: UILabel!
	@IBOutlet var switchOne: UISwitch!
	@IBOutlet var containerView: UIView!
	@IBOutlet var imageSwitchTwo: UIImageView!
	@IBOutlet var descriptionSwitchTwo: UILabel!
	@IBOutlet var switchTwo: UISwitch!
	
	@IBOutlet var heightContainerConstraint: NSLayoutConstraint!
	@IBOutlet var heightImageSwitchTwoConstraint: NSLayoutConstraint!
	@IBOutlet var heightDescriptionSwitchTwoConstraint: NSLayoutConstraint!
	@IBOutlet var heightSwitchTwoConstraint: NSLayoutConstraint!
	
	var id = ""
	
	var sheetTheme: VTheme?
	var tagAttribute: ThemeAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	
	var isActive = false { didSet { showSecondSwitch() } }
	var delegate: LabelDoubleSwitchDelegate?
	var preferredHeight: CGFloat {
		return switchOne.isOn ? 120 : 60
	}
	
	private var switchThumbNailColorOne: UIColor {
		return self.switchOne.isOn ? isThemeLight ? .white : .black : isThemeLight ? .white : UIColor(hex: "FF8324")!
	}
	private var switchBackgroundColorOne: UIColor {
		return self.switchOne.isOn ? isThemeLight ? .blue : UIColor(hex: "FF8324")! : isThemeLight ? .white : .darkGray
	}
	private var switchThumbNailColorTwo: UIColor {
		return self.switchTwo.isOn ? isThemeLight ? .white : .black : isThemeLight ? .white : UIColor(hex: "FF8324")!
	}
	private var switchBackgroundColorTwo: UIColor {
		return self.switchTwo.isOn ? isThemeLight ? .blue : UIColor(hex: "FF8324")! : isThemeLight ? .white : .darkGray
	}
	
	static let identifier = "LabelDoubleSwitchCell"
	
	override func awakeFromNib() {
		imageSwitchTwo.tintColor = themeHighlighted
		imageSwitchTwo.image = Cells.arrowSub
		switchOne.isOn = false
		switchTwo.isOn = false
		setSwitchColors()
		showSecondSwitch()
	}

	
	static func create(id: String, descriptionSwitchOne: String, descriptionSwitchTwo: String) -> LabelDoubleSwitchCell {
		let view : LabelDoubleSwitchCell! = UIView.create(nib: "LabelDoubleSwitchCell")
		view.id = id
		view.descriptionSwitchOne.text = descriptionSwitchOne
		view.descriptionSwitchTwo.text = descriptionSwitchTwo
		view.imageSwitchTwo.tintColor = themeHighlighted
		view.imageSwitchTwo.image = Cells.arrowSub
		view.switchOne.isOn = false
		view.switchOne.thumbTintColor = isThemeLight ? .white : UIColor(hex: "FF8324")
		view.switchTwo.thumbTintColor = isThemeLight ? .white : UIColor(hex: "FF8324")
		view.switchTwo.isOn = false
		if !isThemeLight {
			view.switchTwo.tintColor = .primary
			view.switchTwo.onTintColor = .primary
			view.switchOne.tintColor = .primary
			view.switchOne.onTintColor = .primary
		}
		view.showSecondSwitch()
		view.imageSwitchTwo.image = #imageLiteral(resourceName: "ArrowSub")
		view.imageSwitchTwo.tintColor = UIColor(hex: "FF8324")
		return view
	}
	
	func setSwitches(first: Bool?, second: Bool?) {
		if switchOne.isOn != first {
			switchOne.isOn = first ?? false
			switchOneChanged(switchOne)
		}
		switchOne.isOn = first ?? false

		switchTwo.isOn = second ?? false
		switchTwoChanged(switchTwo)
		
		delegate?.didSelectSwitch(first: first ?? false, second: second ?? false, cell: self)
		layoutIfNeeded()
	}
	
	func showSecondSwitch() {
		if switchOne.isOn {
			heightContainerConstraint.constant = 60
			containerView.isHidden = false
			heightImageSwitchTwoConstraint.constant = 20
			heightDescriptionSwitchTwoConstraint.constant = 21
			heightSwitchTwoConstraint.constant = 31
		} else {
			containerView.isHidden = true
			heightContainerConstraint.constant = 1
			heightImageSwitchTwoConstraint.constant = 1
			heightDescriptionSwitchTwoConstraint.constant = 1
			heightSwitchTwoConstraint.constant = 1
		}
		
	}
	
	func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
		self.sheetTheme = theme
		self.tagAttribute = themeAttribute
		self.descriptionSwitchOne.text = themeAttribute.description
		self.descriptionSwitchTwo.text = Text.NewTheme.descriptionPositionEmptySheet
		self.applyValueToCell()
	}
	
	func applyValueToCell() {
		if let tag = sheetTheme, let tagAttribute = tagAttribute {
			switch tagAttribute {
			case .hasEmptySheet: switchOne.isOn = tag.hasEmptySheet
			case .isEmptySheetFirst: switchTwo.isOn = tag.isEmptySheetFirst
			default: return
			}
		}
		setSwitchColors()
	}
	
	func applyCellValueToTag() {
		if let tag = sheetTheme, let tagAttribute = tagAttribute {
			switch tagAttribute {
			case .hasEmptySheet: tag.hasEmptySheet = switchOne.isOn
			case .isEmptySheetFirst: tag.isEmptySheetFirst = switchTwo.isOn
			default: return
			}
		}
	}
	
	func set(value: Any?) {
		if let tagAttribute = tagAttribute, let value = value as? Bool? {
			switch tagAttribute {
			case .hasEmptySheet: switchOne.isOn = value ?? false
			case .isEmptySheetFirst: switchTwo.isOn = value ?? false
			default: return
			}
		}
	}
	
	private func setSwitchColors() {
		switchOne.thumbTintColor = switchThumbNailColorOne
		switchTwo.thumbTintColor = switchThumbNailColorTwo
		switchOne.onTintColor = switchBackgroundColorOne
		switchTwo.onTintColor = switchBackgroundColorTwo
	}
	
	@IBAction func switchOneChanged(_ sender: UISwitch) {
		setSwitchColors()
		if !switchOne.isOn {
			switchTwo.isOn = false
			switchTwoChanged(switchTwo)
		}
		isActive = switchOne.isOn
		showSecondSwitch()
		applyCellValueToTag()
		valueDidChange?(self)
	}
	
	@IBAction func switchTwoChanged(_ sender: UISwitch) {
		setSwitchColors()
		applyCellValueToTag()
		valueDidChange?(self)
	}
	
	
}
