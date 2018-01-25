//
//  LabelNumberCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelNumerCellDelegate {
	func numberChangedForCell(cell: LabelNumberCell)
}

class LabelNumberCell: UITableViewCell {
	
	@IBOutlet var minus: UIButton!
	@IBOutlet var plus: UIButton!
	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var valueLabel: UILabel!
	
	var id: String = ""
	var positive = true
	var value: Int = 0
	var delegate: LabelNumerCellDelegate?
	let preferredHeight: CGFloat = 60
	
	static func create(id: String, description: String, initialValue: Int, positive: Bool = true) -> LabelNumberCell {
		let view : LabelNumberCell! = UIView.create(nib: "LabelNumberCell")
		view.id = id
		view.descriptionTitle.text = description
		view.positive = positive
		view.value = initialValue
		view.plus.tintColor = themeHighlighted
		view.minus.tintColor = themeHighlighted
		view.valueLabel.text = String(initialValue)
		return view
	}
	
	func setValue(value: Int) {
		self.value = value
		valueLabel.text = String(value)
		delegate?.numberChangedForCell(cell: self)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	@IBAction func minusPressed(_ sender: UIButton) {
			if positive {
				if value > 4 {
					value -= 1
					self.valueLabel.text = String(value)
					delegate?.numberChangedForCell(cell: self)
				}
			} else {
				if value < 0 {
					value += 1
					self.valueLabel.text = String(abs(value))
					delegate?.numberChangedForCell(cell: self)
				}
			}
	}
	
	@IBAction func plusPressed(_ sender: UIButton) {
			if positive {
				if value < 49 {
					value += 1
					self.valueLabel.text = String(value)
					delegate?.numberChangedForCell(cell: self)
				}
			} else {
				if value > -18 {
					value -= 1
					self.valueLabel.text = String(abs(value))
					delegate?.numberChangedForCell(cell: self)
				}
				
			}
		}
	
    
}
