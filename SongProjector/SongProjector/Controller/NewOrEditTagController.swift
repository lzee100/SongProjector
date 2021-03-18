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

class NewOrEditThemeController: ChurchBeamViewController, UITextFieldDelegate {

	@IBOutlet var pageDescription: UILabel!
	@IBOutlet var inputField: UITextField!
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var errorDescription: UILabel!
	
	// title
	
	
	// lyrics
	
	
	
	var delegate: NewOrEditThemeControllerDelegate?
	
	override func viewDidLoad() {
		inputField.delegate = self
		pageDescription.text = AppText.NewTheme.pageDescription
		errorDescription.text = ""
		errorDescription.textColor = .errorColor
		saveButton.setTitle(AppText.Actions.add, for: .normal)
	}
	
	@IBAction func saveButtonPressed(_ sender: UIButton) {
		if inputField.text != "" {
            let theme: Theme = DataFetcher().createEntity(moc: moc)
			theme.title = inputField.text
            do {
                try moc.save()
                delegate?.hasNewTheme()
                dismiss(animated: true)
            } catch {
                show(message: error.localizedDescription)
            }
		} else {
			errorDescription.text = AppText.NewTheme.errorMessage
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

		let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let compSepByCharInSet = string.components(separatedBy: aSet)
		let numberFiltered = compSepByCharInSet.joined(separator: "")
		return string == numberFiltered
	}
	
}
