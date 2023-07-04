//
//  GoogleCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

protocol GoogleCellDelegate {
	func showInstructions(cell: GoogleCell)
	func didSuccesfullyLogin(googleIdToken: String, userName: String)
}

let GoogleMail = "googleEmail"
let GoogleIdToken = "googleIdToken"
let GoogleUsername = "GoogleUsername"


class GoogleCell: UITableViewCell {
		
	@IBOutlet var instructionButton: UIButton!
	@IBOutlet var googleSignInOutContainer: UIView!
    @IBOutlet var signOutContainerView: UIView!
    @IBOutlet var signOutButton: UIButton!
    
	
	let signInButton = GIDSignInButton()
	
	static let preferredHeight: CGFloat = 150
	
	var id = ""
	var sender = UIViewController()
	
	static let identifier = "GoogleCell"
	
    override func prepareForReuse() {
        super.prepareForReuse()
        signOutContainerView.isHidden = true
        signOutButton.isUserInteractionEnabled = false
    }
	
	func setup(delegate: GoogleCellDelegate, sender: UIViewController) {
        
        let isSignedIn = Auth.auth().currentUser != nil || GIDSignIn.sharedInstance.currentUser != nil
        
        signOutButton.isUserInteractionEnabled = isSignedIn
        signOutContainerView.isHidden = !isSignedIn
        
        if !isSignedIn {
            googleSignInOutContainer.addSubview(signInButton)
            signInButton.frame = googleSignInOutContainer.bounds
            GIDSignIn.sharedInstance.signIn(withPresenting: sender)
            self.sender = sender
            instructionButton.setTitle(AppText.Settings.descriptionInstructions, for: .normal)
            instructionButton.tintColor = themeHighlighted
            googleSignInOutContainer.backgroundColor = themeWhiteBlackBackground
        }
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
		if error == nil, let token = user.idToken?.tokenString, let email = user.profile?.email {
            delegate?.didSuccesfullyLogin(googleIdToken: token, userName: email)
//            GoogleActivityFetcher.fetch(force: true)
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
	
    @IBAction func didPressSignOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        GIDSignIn.sharedInstance.signOut()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
}
