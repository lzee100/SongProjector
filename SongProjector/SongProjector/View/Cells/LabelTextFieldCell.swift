//
//  LabelTextFieldCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelTextFieldCellDelegate {
	func textFieldDidChange(cell: LabelTextFieldCell, text: String?)
}

class LabelTextFieldCell: ChurchBeamCell, ThemeImplementation, SheetImplementation {

	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var textField: UITextField!
	
	var id = ""
	var delegate: LabelTextFieldCellDelegate?
	
	var sheet: VSheet?
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var sheetAttribute: SheetAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	var getModificationMode: (() -> ModificationMode)?
	
	static let identifier = "LabelTextFieldCell"
	
	static var identitier: String { return "LabelTextFieldCell" }
	
	override func awakeFromNib() {
		textField.addTarget(self, action: #selector(textFieldDidChange),
							for: UIControlEvents.editingChanged)
	}
	
	static func create(id: String, description: String, placeholder: String) -> LabelTextFieldCell {
		let view : LabelTextFieldCell! = UIView.create(nib: "LabelTextFieldCell")
		view.id = id
		view.descriptionTitle.text = description
		view.textField.placeholder = placeholder
		view.textField.addTarget(view, action: #selector(view.textFieldDidChange),
								 for: UIControlEvents.editingChanged)
		return view
	}
	
	func create(id: String, description: String, placeholder: String) {
		self.id = id
		descriptionTitle.text = description
		textField.placeholder = placeholder
		textField.addTarget(self, action: #selector(textFieldDidChange),
								 for: UIControlEvents.editingChanged)
	}
	
	func setup(description: String?, placeholder: String, delegate: LabelTextFieldCellDelegate) {
		descriptionTitle.text = description
		textField.placeholder = placeholder
		self.delegate = delegate
	}
	
	func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
		self.sheetTheme = theme
		self.themeAttribute = themeAttribute
		descriptionTitle.text = themeAttribute.description
		applyValueToCell()
	}
	
	func apply(sheet: VSheet, sheetAttribute: SheetAttribute) {
		self.sheet = sheet
		self.sheetAttribute = sheetAttribute
		descriptionTitle.text = sheetAttribute.description
		self.applyValueToCell()
	}
	
	func applyValueToCell() {
		
		if let modificationMode = getModificationMode?() {
			switch modificationMode {
			case .newTheme, .editTheme:
				textField.text = sheetTheme?.title ?? Text.NewTheme.sampleTitle
			case .newCustomSheet, .editCustomSheet:
				textField.text = sheet?.title ?? Text.NewTheme.sampleTitle
			}
		}
	}
	
	func applyCellValueToTheme() {
		
		if let modificationMode = getModificationMode?() {
			switch modificationMode {
			case .newTheme, .editTheme:
				sheetTheme?.title = textField.text ?? Text.NewTheme.sampleTitle
			case .newCustomSheet, .editCustomSheet:
				sheet?.title = textField.text
			}
		}
		
		if let themeAttribute = themeAttribute, let theme = sheetTheme {
			switch themeAttribute {
			case .title: theme.title = self.textField.text
			default:
				return
			}
		}
		
	}
	
	func set(value: Any?) {
		guard value != nil else {
			setName(name: "")
			return
		}
		if let value = value as? String {
			setName(name: value)
		}
	}
	
	func setName(name: String) {
		textField.text = name
		applyCellValueToTheme()
		delegate?.textFieldDidChange(cell: self, text: textField.text)
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
		
    }
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	@objc func textFieldDidChange() {
		applyCellValueToTheme()
		valueDidChange?(self)
		delegate?.textFieldDidChange(cell: self, text: textField.text)
	}
    
}
