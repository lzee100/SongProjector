//
//  SignUpOrganisationController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit

class SignUpOrganisationController: ChurchBeamViewController {

	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var nextButton: UIBarButtonItem!

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!

	@IBOutlet var nameExplanation: UILabel!
	@IBOutlet var nameTextField: UITextField!
	
	
	var contract: Contract? {
		return signInContractSelection.contract
	}
	var organizationName = ""
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination.unwrap() as? SignUpPersonalInfoController {
			vc.organizationName = organizationName
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = themeWhiteBlackBackground
		titleLabel.text = contract?.name
		titleLabel.textColor = themeWhiteBlackTextColor
		contentLabel.textColor = themeWhiteBlackTextColor
		nameExplanation.textColor = themeWhiteBlackTextColor
		nameTextField.text = "kerk"
		let content = "Wat leuk dat je aan de slag gegaat met de %@ versie van ChurchBeam.\nOm goed van start te kunnen gaan hebben we wat informatie nodig van je."
		contentLabel.text = content.replacingOccurrences(of: "%@", with: contract?.name ?? "")
		
		nameTextField.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
		
//		nextButton.isEnabled = false
		nextButton.title = Text.Actions.next
	}
	
	@objc func textfieldDidChange() {
		organizationName = nameTextField.text ?? ""
		nextButton.isEnabled = !organizationName.isBlanc
	}
	
	@IBAction func didPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
}
