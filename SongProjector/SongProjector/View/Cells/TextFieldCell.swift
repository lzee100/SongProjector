//
//  TextFieldCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18-08-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var textField: UITextField!
    @IBOutlet var labelTextFieldConstraint: NSLayoutConstraint!
    
	static let identifier = "TextFieldCell"
	
	private var textFieldDidChange: ((String?) -> Void)?
	
	override func prepareForReuse() {
		super.prepareForReuse()
		textField.text = nil
	}
	
	func setup(description: String?, content: String?, textFieldDidChange: @escaping ((String?) -> Void)) {
        labelTextFieldConstraint.constant = description == nil ? 0 : 10
		descriptionLabel.text = description
		textField.text = content
		self.textFieldDidChange = textFieldDidChange
	}
	
	@IBAction func textfieldDidEdit(_ sender: UITextField) {
		textFieldDidChange?(sender.text)
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
    
}
