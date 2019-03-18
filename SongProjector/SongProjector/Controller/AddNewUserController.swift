//
//  AddNewUserController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class AddNewUserController: ChurchBeamViewController {
	
	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var sendButton: UIBarButtonItem!
	
	@IBOutlet var contentLabel: UILabel!
	@IBOutlet var userNameTextField: UITextField!
	@IBOutlet var emailTextField: UITextField!
	@IBOutlet var inviteCodeLabel: UILabel!
	
	
	
	// MARK: - Private properties

	private var inviteCode: String = ""
	
	
	
	// MARK: - View Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		contentLabel.text = "Het toevoegen van een nieuwe gebruiker gaat heel simpel: voer een gebruikersnaam in voor herkenning van de gebruikers voor jouw organisatie en een emailadres. De nieuwe gebruiker ontvangt een email met de koppelcode om het deel te nemen. \nElke nieuwe gebruiker kost 3 euro per maand en kan altijd weer opgezegd worden."
		
		userNameTextField.placeholder = "Gebruikersnaam"
		emailTextField.placeholder = "Emailadres voor koppelcode"
		
		generateInviteCode()
		inviteCodeLabel.text = inviteCode
		UserSubmitter.addObserver(self)
    }
	
	override func handleRequestFinish(result: AnyObject?) {
		if (result as? [User]) != nil {
			Queues.main.async {
				self.dismiss(animated: true)
			}
		}
	}
	
	
	
	// MARK: - Private Functions
	private func generateInviteCode() {
		let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let first = String((0...6).map{ _ in letters.randomElement()! })
		let second = String((0...6).map{ _ in letters.randomElement()! })
		let third = String((0...6).map{ _ in letters.randomElement()! })
		
		inviteCode = first + "-" + second + "-" + third
	}
	
	
	
	// MARK: - IBAction Functions
	
	@IBAction func didPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func didPressSend(_ sender: UIBarButtonItem) {
		let user = CoreUser.createEntityNOTsave()
		let roleId = CoreRole.getEntities().first?.id
		user.title = userNameTextField.text
		user.inviteToken = inviteCode
		user.roleId = roleId ?? 0
		UserSubmitter.submit([user], requestMethod: .post)
	}
	
	
}
