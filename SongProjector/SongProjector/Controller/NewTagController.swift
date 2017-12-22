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

class NewTagController: UIViewController {

	@IBOutlet var pageDescription: UILabel!
	@IBOutlet var inputField: UITextField!
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var errorDescription: UILabel!
	
	var delegate: NewTagControllerDelegate?
	
	override func viewDidLoad() {
		pageDescription.text = Text.NewTag.pageDescription
		errorDescription.text = Text.NewTag.error
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
			errorDescription.text = Text.Actions.add
		}
	}
	
}
