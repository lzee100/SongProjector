//
//  LabelColorPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol LabelColorPickerCellDelegate {
	func colorPickerDidChooseColor(cell: LabelColorPickerCell, colorPicker: ChromaColorPicker, color: UIColor)
}

class LabelColorPickerCell: UITableViewCell, ChromaColorPickerDelegate {

	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var colorPickerContainer: UIView!
	@IBOutlet var colorPreview: UIView!
	
	var preferredHeight : CGFloat {
		return isActive ? 360 : 60
	}
	
	var id = ""
	var isActive = false { didSet { setupColorPicker() } }
	var colorPicker = ChromaColorPicker()
	
	static func create(id: String, description: String) -> LabelColorPickerCell {
		let view : LabelColorPickerCell! = UIView.create(nib: "LabelColorPickerCell")
		view.id = id
		view.descriptionTitle.text = description
		return view
	}
	
	var delegate: LabelColorPickerCellDelegate?
	
	
	private func setupColorPicker() {
		if isActive {
			colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
			colorPicker.delegate = self
			colorPicker.padding = 5
			colorPicker.stroke = 3
			colorPicker.hexLabel.textColor = UIColor.white
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.colorPickerContainer.addSubview(self.colorPicker)
			})
		} else {
			self.colorPicker.removeFromSuperview()
		}
	}
	
	func setColor(color: UIColor) {
		colorPreview.backgroundColor = color
		colorPicker.adjustToColor(color)
		delegate?.colorPickerDidChooseColor(cell: self, colorPicker: colorPicker, color: color)
	}
	
	func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
		colorPreview.backgroundColor = color
		isActive = !isActive
		delegate?.colorPickerDidChooseColor(cell: self, colorPicker: colorPicker, color: color)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
	
	
}
