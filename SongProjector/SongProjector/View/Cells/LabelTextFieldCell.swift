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

class LabelTextFieldCell: UITableViewCell {

	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var textField: UITextField!
	
	var id = ""
	var delegate: LabelTextFieldCellDelegate?
	
	static func create(id: String, description: String, placeholder: String) -> LabelTextFieldCell {
		let view : LabelTextFieldCell! = UIView.create(nib: "LabelTextFieldCell")
		view.id = id
		view.descriptionTitle.text = description
		view.textField.placeholder = placeholder
		view.textField.addTarget(view, action: #selector(view.textFieldDidChange),
								 for: UIControlEvents.editingChanged)
		return view
	}
	
	func setName(name: String) {
		textField.text = name
		delegate?.textFieldDidChange(cell: self, text: textField.text)
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
		
    }
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
	@objc func textFieldDidChange() {
		delegate?.textFieldDidChange(cell: self, text: textField.text)
	}
    
}
