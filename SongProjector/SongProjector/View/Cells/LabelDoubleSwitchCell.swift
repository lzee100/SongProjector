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

class LabelDoubleSwitchCell: ChurchBeamCell, DynamicHeightCell, ThemeImplementation {
	
    static let identifier = "LabelDoubleSwitchCell"

	@IBOutlet var descriptionSwitchOne: UILabel!
	@IBOutlet var switchOne: UISwitch!
	@IBOutlet var containerView: UIView!
	@IBOutlet var imageSwitchTwo: UIImageView!
	@IBOutlet var descriptionSwitchTwo: UILabel!
	@IBOutlet var switchTwo: UISwitch!
	
    @IBOutlet var subContainerTopConstraint: NSLayoutConstraint!
	@IBOutlet var heightImageSwitchTwoConstraint: NSLayoutConstraint!
	@IBOutlet var heightDescriptionSwitchTwoConstraint: NSLayoutConstraint!
	@IBOutlet var heightSwitchTwoConstraint: NSLayoutConstraint!
	
	var id = ""
	
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	
	var isActive = false { didSet { showSecondSwitch() } }
	var delegate: LabelDoubleSwitchDelegate?
	var preferredHeight: CGFloat {
		return switchOne.isOn ? 120 : 60
	}
    	
	override func awakeFromNib() {
        imageSwitchTwo.tintColor = .softBlueGrey
		imageSwitchTwo.image = Cells.arrowSub
		switchOne.isOn = false
		switchTwo.isOn = false
        switchOne.thumbTintColor = .whiteColor
        switchTwo.thumbTintColor = .whiteColor
        heightImageSwitchTwoConstraint.constant = 20
        heightDescriptionSwitchTwoConstraint.constant = 21
        heightSwitchTwoConstraint.constant = 31
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
		view.switchOne.thumbTintColor = isThemeLight ? .whiteColor : UIColor(hex: "FF8324")
		view.switchTwo.thumbTintColor = isThemeLight ? .whiteColor : UIColor(hex: "FF8324")
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
        UIView.animate(withDuration: 0.4) {
            self.containerView.alpha = self.switchOne.isOn ? 1 : 0
            self.subContainerTopConstraint.constant = self.switchOne.isOn ? self.bounds.height : 0
        }
	}
	
	func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
		self.sheetTheme = theme
		self.themeAttribute = themeAttribute
		self.descriptionSwitchOne.text = themeAttribute.description
		self.descriptionSwitchTwo.text = AppText.NewTheme.descriptionPositionEmptySheet
		self.applyValueToCell()
	}
	
	func applyValueToCell() {
		switchOne.isOn = sheetTheme?.hasEmptySheet ?? false
		switchTwo.isOn = sheetTheme?.isEmptySheetFirst ?? false
	}
	
	func applyCellValueToTheme() {
		sheetTheme?.hasEmptySheet = switchOne.isOn
		sheetTheme?.isEmptySheetFirst = switchTwo.isOn
	}
	
	func set(value: Any?) {
		if let themeAttribute = themeAttribute, let value = value as? Bool? {
			switch themeAttribute {
			case .hasEmptySheet:
				switchOne.isOn = value ?? false
				switchTwo.isOn = value ?? false
			case .isEmptySheetFirst:
				switchOne.isOn = value ?? false
				switchTwo.isOn = value ?? false
			default: return
			}
		}
	}
	
	@IBAction func switchOneChanged(_ sender: UISwitch) {
		if !switchOne.isOn {
			switchTwo.isOn = false
			switchTwoChanged(switchTwo)
		}
		isActive = switchOne.isOn
		showSecondSwitch()
		applyCellValueToTheme()
		valueDidChange?(self)
	}
	
	@IBAction func switchTwoChanged(_ sender: UISwitch) {
		applyCellValueToTheme()
		valueDidChange?(self)
	}
	
	
}
