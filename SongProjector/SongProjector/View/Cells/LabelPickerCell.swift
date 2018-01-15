//
//  LabelPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelPickerCellDelegate {
	func didSelect(item: (Int64, String), cell: LabelPickerCell)
}

class LabelPickerCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {


	@IBOutlet var descriptionTitel: UILabel!
	@IBOutlet var fontLabel: UILabel!
	@IBOutlet var pickerHolder: UIView!
	
	var preferredHeight: CGFloat {
		return isActive ? 360 : 60
	}
	
	var id: String = ""
	var isActive = false { didSet { updatePicker() } }
	var delegate: LabelPickerCellDelegate?
	var pickerValues: [(Int64, String)] = []
	var picker = UIPickerView()
	
	static func create(id: String, description: String, initialValueName: String, pickerValues: [(Int64, String)]) -> LabelPickerCell {
		let view : LabelPickerCell! = UIView.create(nib: "LabelPickerCell")
		view.id = id
		view.descriptionTitel.text = description
		view.fontLabel.text = initialValueName
		view.picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
		view.picker.dataSource = view
		view.picker.delegate = view
		view.pickerHolder.backgroundColor = themeWhiteBlackBackground
		view.pickerValues = pickerValues
		return view
	}
	
	func setValue(value: String? = nil, id: Int16? = nil) {
		if let value = value, let index = pickerValues.index(where: { (item) -> Bool in item.1 == value }) {
			pickerView(picker, didSelectRow: index, inComponent: 0)
		} else if let id = id, let index = pickerValues.index(where: { (value) -> Bool in value.0 == id }) {
			pickerView(picker, didSelectRow: index, inComponent: 0)
		} else {
			pickerView(picker, didSelectRow: 0, inComponent: 0)
		}
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	
	private func updatePicker() {
		if isActive {
			pickerHolder.isHidden = false
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.pickerHolder.addSubview(self.picker)
			})
		} else {
			pickerHolder.isHidden = true
			picker.removeFromSuperview()
		}
	}
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerValues[row].1
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let title = pickerValues[row].1
		let myTitle = NSAttributedString(string: title, attributes: [ .foregroundColor : themeWhiteBlackTextColor ])
		return myTitle
	}
	
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerValues.count
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		let value = pickerValues[row]
		fontLabel.text = value.1
		delegate?.didSelect(item: value, cell: self)
	}
	
	
    
}
