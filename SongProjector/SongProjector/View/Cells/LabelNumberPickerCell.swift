//
//  LabelNumberPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol LabelNumberPickerCellDelegate {
	func numberPickerValueChanged(cell: LabelNumberPickerCell, value: Int)
}

class LabelNumberPickerCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var descriptionSubtitle: UILabel!
	@IBOutlet var picker: UIPickerView!
	
	static var identitier: String { return "LabelNumberPickerCell" }

	var id: String = ""
	var delegate: LabelNumberPickerCellDelegate?
	var pickerValues: [Int] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,18,20,24,28,34,40,60]
	
	static func create(id: String, description: String, subtitle: String?, initialValue: Int? = nil, values: [Int]? = nil) -> LabelNumberPickerCell {
		let view : LabelNumberPickerCell! = UIView.create(nib: "LabelNumberPickerCell")
		view.id = id
		view.descriptionTitle.text = description
		
		if subtitle == nil {
			view.descriptionSubtitle.isHidden = true
		} else {
			view.descriptionSubtitle.text = subtitle
		}
		
		if let values = values {
			view.pickerValues = values
		}
		
		view.setValue(initialValue)
		
		return view
	}
	
	func create(id: String, description: String, subtitle: String?, initialValue: Int? = 0, values: [Int]? = nil) {
		self.id = id
		descriptionTitle.text = description
		
		if subtitle == nil {
			descriptionSubtitle.isHidden = true
		} else {
			descriptionSubtitle.text = subtitle
		}
		
		if let values = values {
			pickerValues = values
		}
		
		setValue(initialValue)
	}
	
	func setValue(_ value: Int?) {
		if let value = value, let index = pickerValues.index(of: value) {
			picker.selectRow(index, inComponent: 0, animated: false)
		}
	}
	
	
	// MARK: - UIpickerView delegate functions
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerValues.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return String(pickerValues[row])
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let title = String(pickerValues[row])
		let myTitle = NSAttributedString(string: title, attributes: [ .foregroundColor : themeWhiteBlackTextColor ])
		return myTitle
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		delegate?.numberPickerValueChanged(cell: self, value: pickerValues[row])
	}
	
	
	
	// MARK: - UItableviewCell functions
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
}
