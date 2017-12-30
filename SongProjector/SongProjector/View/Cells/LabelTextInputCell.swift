//
//  LabelTextInputCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

// https://github.com/joncardasis/ChromaColorPicker#license

class LabelTextInputCell: TextFieldCell {

	@IBOutlet var descriptionLabel: UILabel!
	
	// MARK: - Functions
	
	static func create(placeholder: String) -> LabelTextInputCell {
		let view : LabelTextInputCell! = UIView.create(nib: "labelTextFieldCell")
		view.placeholder = placeholder
		return view
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
