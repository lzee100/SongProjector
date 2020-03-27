//
//  GoogleSignedInCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol GoogleSignedInCellDelegate {
	func didSignedOut()
}

class GoogleSignedInCell: ChurchBeamCell {

	static let identifier = "GoogleSignedInCell"
	@IBOutlet var profilePictureImageView: UIImageView!
	@IBOutlet var usernameLabel: UILabel!
	@IBOutlet var emailLabel: UILabel!
	@IBOutlet var signOutContainerView: UIView!
	
	let signInButton = GIDSignInButton()
	var sender = UIViewController()
	@IBOutlet var signOutButton: UIButton!
	var delegate: GoogleSignedInCellDelegate?
	static let preferredHeight : CGFloat = 150
	
    override func awakeFromNib() {
        super.awakeFromNib()
		signOutButton.setTitle(Text.Settings.googleSignOutButton, for: .normal)
    }
	
	
	
	@objc func signOut() {
		let userDefaults = UserDefaults.standard
		userDefaults.removeObject(forKey: GoogleMail)
		userDefaults.removeObject(forKey: GoogleIdToken)
		userDefaults.removeObject(forKey: GoogleUsername)
		signOutButton.removeFromSuperview()
		signOutContainerView.addSubview(signInButton)
		GIDSignIn.sharedInstance().signOut()
	}
	
	func setup(delegate: GoogleSignedInCellDelegate, sender: UIViewController) {
		let userDefaults = UserDefaults.standard
		let email = userDefaults.object(forKey: GoogleMail) as? String
		let name = userDefaults.object(forKey: GoogleUsername) as? String

		if let user = GIDSignIn.sharedInstance()?.currentUser {
			if user.profile.hasImage {
				
			} else {
				// set constaint to 0
			}
			emailLabel.text = email
			usernameLabel.text = name
		}

		self.sender = sender
		GIDSignIn.sharedInstance()?.presentingViewController = sender
	}
	
	
	// MARK: Google Fetcher Delegates
	
	func loginDidFailWithError(message: String) {
		let alert = UIAlertController(title: Text.Settings.errorTitleGoogleAuth, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil))
		sender.present(alert, animated: true)
	}
	
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



	@IBAction func didSelectSignOut(_ sender: UIButton) {
		delegate?.didSignedOut()
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
