//
//  NewTagController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol NewTagControllerDelegate {
	func hasNewTag()
}

class NewTagController: UIViewController, UITextFieldDelegate {

	@IBOutlet var pageDescription: UILabel!
	@IBOutlet var inputField: UITextField!
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var errorDescription: UILabel!
	
	// title
	
	
	// lyrics
	
	
	
	var delegate: NewTagControllerDelegate?
	
	override func viewDidLoad() {
		inputField.delegate = self
		pageDescription.text = Text.NewTag.pageDescription
		errorDescription.text = ""
		errorDescription.textColor = .errorColor
		saveButton.setTitle(Text.Actions.add, for: .normal)
	}
	
	@IBAction func saveButtonPressed(_ sender: UIButton) {
		if inputField.text != "" {
			let tag = CoreTag.createEntity()
			tag.title = inputField.text
			let _ = CoreTag.saveContext()
			delegate?.hasNewTag()
			dismiss(animated: true)
		} else {
			errorDescription.text = Text.NewTag.error
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

		let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let compSepByCharInSet = string.components(separatedBy: aSet)
		let numberFiltered = compSepByCharInSet.joined(separator: "")
		return string == numberFiltered
	}
	
}
