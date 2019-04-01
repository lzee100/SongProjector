//
//  NewOrEditThemeController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol NewOrEditThemeControllerDelegate {
	func hasNewTheme()
}

class NewOrEditThemeController: UIViewController, UITextFieldDelegate {

	@IBOutlet var pageDescription: UILabel!
	@IBOutlet var inputField: UITextField!
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var errorDescription: UILabel!
	
	// title
	
	
	// lyrics
	
	
	
	var delegate: NewOrEditThemeControllerDelegate?
	
	override func viewDidLoad() {
		inputField.delegate = self
		pageDescription.text = Text.NewTheme.pageDescription
		errorDescription.text = ""
		errorDescription.textColor = .errorColor
		saveButton.setTitle(Text.Actions.add, for: .normal)
	}
	
	@IBAction func saveButtonPressed(_ sender: UIButton) {
		if inputField.text != "" {
			let theme = CoreTheme.createEntity()
			theme.title = inputField.text
			let _ = CoreTheme.saveContext()
			delegate?.hasNewTheme()
			dismiss(animated: true)
		} else {
			errorDescription.text = Text.NewTheme.errorMessage
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

		let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let compSepByCharInSet = string.components(separatedBy: aSet)
		let numberFiltered = compSepByCharInSet.joined(separator: "")
		return string == numberFiltered
	}
	
}
