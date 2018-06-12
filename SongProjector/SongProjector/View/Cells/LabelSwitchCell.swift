//
//  LabelSwitchCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelSwitchCellDelegate {
	func valueChangedFor(cell: LabelSwitchCell, uiSwitch: UISwitch)
}

class LabelSwitchCell: ChurchBeamCell {

	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var `switch`: UISwitch!
	
	
	var id = ""
	var delegate: LabelSwitchCellDelegate?
	let preferredHeight: CGFloat = 60
	
	static func create(id: String, description: String, initialValueIsOn: Bool = false) -> LabelSwitchCell {
		let view : LabelSwitchCell! = UIView.create(nib: "LabelSwitchCell")
		view.id = id
		view.descriptionLabel.text = description
		view.switch.isOn = initialValueIsOn
		view.switch.thumbTintColor = initialValueIsOn ? isThemeLight ? .white : .black : isThemeLight ? .white : UIColor(hex: "FF8324")
		if !isThemeLight {
			view.switch.onTintColor = .primary
			view.switch.tintColor = .primary
		}
		return view
	}
	
	func setSwitchValueTo(value: Bool) {
		self.`switch`.isOn = value
		valueChanged(`switch`)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	@IBAction func valueChanged(_ sender: UISwitch) {
		`switch`.thumbTintColor = sender.isOn ? isThemeLight ? .white : .black : isThemeLight ? .white : UIColor(hex: "FF8324")
		delegate?.valueChangedFor(cell: self, uiSwitch: sender)
	}
	
	
}
