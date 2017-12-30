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

class LabelSwitchCell: UITableViewCell {

	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var `switch`: UISwitch!
	
	
	var id = ""
	var delegate: LabelSwitchCellDelegate?
	let preferredHeight: CGFloat = 60

	static func create(id: String, description: String, initialValueIsOn: Bool = false) -> LabelSwitchCell {
		let view : LabelSwitchCell! = UIView.create(nib: "LabelSwitchCell")
		view.id = id
		view.switch.tintColor = .primary
		view.switch.onTintColor = .primary
		view.descriptionLabel.text = description
		view.switch.isOn = initialValueIsOn
		return view
	}
	
	func setSwitchValueTo(value: Bool) {
		self.switch.isOn = value
		delegate?.valueChangedFor(cell: self, uiSwitch: self.switch)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	@IBAction func valueChanged(_ sender: UISwitch) {
		delegate?.valueChangedFor(cell: self, uiSwitch: sender)
	}
	
	
}
