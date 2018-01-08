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

class LabelDoubleSwitchCell: UITableViewCell {

	
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
	var delegate: LabelDoubleSwitchDelegate?
	var preferredHeight: CGFloat {
		return switchOne.isOn ? 120 : 60
	}
	
	static func create(id: String, descriptionSwitchOne: String, descriptionSwitchTwo: String) -> LabelDoubleSwitchCell {
		let view : LabelDoubleSwitchCell! = UIView.create(nib: "LabelDoubleSwitchCell")
		view.id = id
		view.descriptionSwitchOne.text = descriptionSwitchOne
		view.descriptionSwitchTwo.text = descriptionSwitchTwo
		view.imageSwitchTwo.tintColor = .primary
		view.switchOne.isOn = false
		view.switchOne.tintColor = .primary
		view.switchOne.onTintColor = .primary
		view.switchTwo.tintColor = .primary
		view.switchTwo.onTintColor = .primary
		view.showSecondSwitch()
		view.imageSwitchTwo.image = #imageLiteral(resourceName: "Bullet")
		return view
	}
	
	func setSwitches(first: Bool?, second: Bool?) {
		if switchOne.isOn != first {
			switchOne.isOn = first ?? false
			switchOneChanged(switchOne)
		}
		switchOne.isOn = first ?? false

		switchTwo.isOn = second ?? false
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
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	@IBAction func switchOneChanged(_ sender: UISwitch) {
		showSecondSwitch()
		delegate?.didSelectSwitch(first: sender.isOn, second: nil, cell: self)
	}
	
	@IBAction func switchTwoChanged(_ sender: UISwitch) {
		delegate?.didSelectSwitch(first: nil, second: sender.isOn, cell: self)
	}
	
	
}
