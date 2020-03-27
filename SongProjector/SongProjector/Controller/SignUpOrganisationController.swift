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
	
	
	override var requesters: [RequesterType] {
		return [UploadSecretFetcher]
	}
	
	var contract: VContract? {
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
		nameTextField.text = "Upload organization"
		let content = "Wat leuk dat je aan de slag gegaat met de %@ versie van ChurchBeam.\nOm goed van start te kunnen gaan hebben we wat informatie nodig van je."
		contentLabel.text = content.replacingOccurrences(of: "%@", with: contract?.name ?? "")
		
		nameTextField.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
		
//		nextButton.isEnabled = false
		nextButton.title = Text.Actions.next
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}

	// Enable detection of shake motion
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			let alert = UIAlertController(title: "Voer code in:", message: nil, preferredStyle: .alert)
			alert.addTextField { (textField) in
				textField.placeholder = "Code"
			}
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: { (_) in
				let secret = alert.textFields![0].text ?? ""
				UploadSecretFetcher.secret = secret
				UploadSecretFetcher.fetch()
			}))
			present(alert, animated: true)
		}
	}
	
	
	
	// MARK: - Delegate Functions
	
	// MARK: RequestObserver Functions
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		if requesterId == UploadSecretFetcher.requesterId {
			UserDefaults.standard.setValue(UploadSecretFetcher.secret, forKey: secretKey)
			NotificationCenter.default.post(name: NotificationNames.secretChanged, object: nil, userInfo: nil)
		}
	}
	
	@objc func textfieldDidChange() {
		organizationName = nameTextField.text ?? ""
		nextButton.isEnabled = !organizationName.isBlanc
	}
	
	@IBAction func didPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
}
