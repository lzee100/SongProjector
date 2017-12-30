//
//  LabelPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelPickerCellDelegate {
	func didSelectFontWith(name: String, cell: LabelPickerCell)
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
	var pickerValues: [String] = []
	var picker = UIPickerView()
	
	static func create(id: String, description: String, initialFontName: String, positive: Bool = true) -> LabelPickerCell {
		let view : LabelPickerCell! = UIView.create(nib: "LabelPickerCell")
		view.id = id
		view.descriptionTitel.text = description
		view.fontLabel.text = initialFontName
		view.picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
		view.picker.dataSource = view
		view.picker.delegate = view
		view.pickerValues = UIFont.familyNames
		return view
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	
	private func updatePicker() {
		if isActive {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.pickerHolder.addSubview(self.picker)
			})
		} else {
			picker.removeFromSuperview()
		}
	}
	
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerValues[row]
	}
	
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerValues.count
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let value = pickerValues[row]
		fontLabel.text = value
		delegate?.didSelectFontWith(name: value, cell: self)
	}
	
	
    
}
