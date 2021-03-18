//
//  PickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-08-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class PickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var valueLabel: UILabel!
	@IBOutlet var pickerView: UIPickerView!
	
	@IBOutlet var pickerViewZeroHeightConstraint: NSLayoutConstraint!
	@IBOutlet var pickerViewHeightConstraint: NSLayoutConstraint!
	
	static let identifier = "PickerCell"
	
	var values: [Any] = []
	var didSelectValue: ((Any) -> Void)?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		valueLabel.text = "0"
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.clear
		selectedBackgroundView = backgroundView
    }
	
	func setupWith(description: String, values: [Any], selectedIndex: Int, didSelectValue: @escaping ((Any) -> Void)) {
		self.descriptionLabel.text = description
		self.valueLabel.text = "\(values[selectedIndex])"
		self.pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
		self.values = values
		self.didSelectValue = didSelectValue
		update()
	}
	
	private func update() {
		pickerView.isHidden = !self.isSelected
		pickerViewZeroHeightConstraint.isActive = !self.isSelected
		pickerViewHeightConstraint.isActive = self.isSelected
		tableView?.beginUpdates()
		tableView?.endUpdates()
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		update()
    }
	
	@IBAction func didSelectCell(_ sender: UIButton) {
		self.isSelected = !self.isSelected
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return values.count
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		return NSAttributedString(string: "\(values[row])", attributes: [NSAttributedString.Key.foregroundColor : UIColor.blackColor])
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		didSelectValue?(values[row])
		self.isSelected = false
		self.valueLabel.text = "\(values[row])"
	}
    
}
