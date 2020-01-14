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

class LabelNumberCell: ChurchBeamCell, ThemeImplementation {
	
	@IBOutlet var minus: UIButton!
	@IBOutlet var plus: UIButton!
	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var valueLabel: UILabel!
	
	var id: String = ""
	var positive = true
	var value: Int = 0
	var delegate: LabelNumerCellDelegate?
	var minLimit = 0
	var maxLimit = 0
	
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	
	static let identifier = "LabelNumberCell"
	
	override func awakeFromNib() {
		plus.tintColor = themeHighlighted
		minus.tintColor = themeHighlighted
	}
	
	static func create(id: String, description: String, initialValue: Int, positive: Bool = true, minLimit: Int, maxLimit: Int) -> LabelNumberCell {
		let view : LabelNumberCell! = UIView.create(nib: "LabelNumberCell")
		view.id = id
		view.descriptionTitle.text = description
		view.positive = positive
		view.value = initialValue
		view.minLimit = minLimit
		view.maxLimit = maxLimit
		view.plus.tintColor = themeHighlighted
		view.minus.tintColor = themeHighlighted
		view.valueLabel.text = String(initialValue)
		return view
	}
	
	func setup(initialValue: Int? = nil, minLimit: Int = 5, maxLimit: Int = 60, positive: Bool = true) {
		if let initialValue = initialValue {
			self.value = initialValue
		}
		valueLabel.text = String(abs(value))
		self.minLimit = minLimit
		self.maxLimit = maxLimit
		self.positive = positive
	}
	
	func setValue(value: Int) {
		self.value = value
		valueLabel.text = String(value)
		delegate?.numberChangedForCell(cell: self)
	}
	
	func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
		self.sheetTheme = theme
		self.themeAttribute = themeAttribute
		self.descriptionTitle.text = themeAttribute.description
		
		switch themeAttribute {
		case .titleTextSize, .contentTextSize:
			setup(minLimit: 5, maxLimit: 60, positive: true)
		case .titleBorderSize, .contentBorderSize:
			setup(minLimit: 0, maxLimit: -15, positive: false)
		default:
			break
		}
		applyValueToCell()
	}
	
	func applyValueToCell() {
		if let themeAttribute = themeAttribute, let theme = sheetTheme {
			switch themeAttribute {
			case .titleTextSize: value = Int(theme.titleTextSize)
			case .titleBorderSize: value = Int(theme.titleBorderSize)
			case .contentTextSize: value = Int(theme.contentTextSize)
			case .contentBorderSize: value = Int(theme.contentBorderSize)
			default: break
			}
			valueLabel.text = String(abs(value))
		}
	}
	
	func applyCellValueToTheme() {
		if let themeAttribute = themeAttribute, let theme = sheetTheme {
			switch themeAttribute {
			case .titleTextSize: theme.titleTextSize = Float(value)
			case .titleBorderSize: theme.titleBorderSize = Float(value)
			case .contentTextSize: theme.contentTextSize = Float(value)
			case .contentBorderSize: theme.contentBorderSize = Float(value)
			default: return
			}
		}
	}
	
	func set(value: Any?) {
		guard value != nil else {
			setValue(value: 0)
			return
		}
		if let value = value as? Int {
			setValue(value: value)
		}
	}
	
	@IBAction func minusPressed(_ sender: UIButton) {
			if positive {
				if value > minLimit {
					value -= 1
					self.valueLabel.text = String(value)
					self.applyCellValueToTheme()
					valueDidChange?(self)
					delegate?.numberChangedForCell(cell: self)
				}
			} else {
				if value < 0 {
					value += 1
					self.valueLabel.text = String(abs(value))
					self.applyCellValueToTheme()
					valueDidChange?(self)
					delegate?.numberChangedForCell(cell: self)
				}
			}
	}
	
	@IBAction func plusPressed(_ sender: UIButton) {
		if positive {
			if value < maxLimit {
				value += 1
				self.valueLabel.text = String(value)
			}
		} else {
			if value > maxLimit {
				value -= 1
				self.valueLabel.text = String(abs(value))
			}
		}
		self.applyCellValueToTheme()
		valueDidChange?(self)
		delegate?.numberChangedForCell(cell: self)
	}
	
}
