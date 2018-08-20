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
	
	static let identifier = "TextFieldCell"
	
	private var textFieldDidChange: ((String?) -> Void)?
	
	func setup(description: String, content: String?, textFieldDidChange: @escaping ((String?) -> Void)) {
		descriptionLabel.text = description
		textField.text = content
		self.textFieldDidChange = textFieldDidChange
	}
	
	
	@IBAction func textFieldChanged(_ sender: UITextField) {
		textFieldDidChange?(sender.text)
	}
	
	
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
    
}
