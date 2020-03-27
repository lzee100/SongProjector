//
//  GoogleCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn


protocol GoogleCellDelegate {
	func showInstructions(cell: GoogleCell)
	func didSuccesfullyLogin(googleIdToken: String, userName: String)
}

let GoogleMail = "googleEmail"
let GoogleIdToken = "googleIdToken"
let GoogleUsername = "GoogleUsername"


class GoogleCell: UITableViewCell, GIDSignInDelegate {
		
	@IBOutlet var instructionButton: UIButton!
	@IBOutlet var googleSignInOutContainer: UIView!
	
	
	let signInButton = GIDSignInButton()
	
	static let preferredHeight: CGFloat = 150
	
	var id = ""
	var sender = UIViewController()
	
	static let identifier = "GoogleCell"
	
	
	func setup(delegate: GoogleCellDelegate, sender: UIViewController) {
		googleSignInOutContainer.addSubview(signInButton)
		signInButton.frame = googleSignInOutContainer.bounds
		GIDSignIn.sharedInstance()?.delegate = self
		GIDSignIn.sharedInstance()?.presentingViewController = sender

		self.sender = sender
		instructionButton.setTitle(Text.Settings.descriptionInstructions, for: .normal)
		instructionButton.tintColor = themeHighlighted
		googleSignInOutContainer.backgroundColor = themeWhiteBlackBackground
	}
	
	var delegate: GoogleCellDelegate?
	
	@IBAction func instruction(_ sender: UIButton) {
		delegate?.showInstructions(cell: self)
	}
	
	// MARK: Google Fetcher Delegates
	
	func presentLoginViewController(vc: UIViewController) {
		sender.present(vc, animated: true)
	}
	
	func dismissViewController(vc: UIViewController) {
		sender.dismiss(animated: true)
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if error == nil {
			UserDefaults.standard.set(user.authentication.idToken, forKey: GoogleIdToken)
			UserDefaults.standard.set(user.profile.email, forKey: GoogleMail)
			UserDefaults.standard.set(user.profile.name + " " + user.profile.familyName, forKey: GoogleUsername)
			delegate?.didSuccesfullyLogin(googleIdToken: user.authentication.idToken, userName: user.profile.email)
			GoogleActivityFetcher.fetch(true)
		}
	}
	
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		Queues.main.async {
			self.sender.present(viewController, animated: true)
		}
	}
	
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		Queues.main.async {
			viewController.dismiss(animated: true)
		}
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
}
