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
}

class GoogleCell: UITableViewCell, GoogleFetcherLoginDelegate, RequestObserver {
	
	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var descriptionValue: UILabel!
	@IBOutlet var instructionButton: UIButton!
	@IBOutlet var googleSignInOutContainer: UIView!
	
	
	let signInButton = GIDSignInButton()
	var signOutButton = UIButton()

	var preferredHeight : CGFloat {
		return 151
	}
	var requesterId: String {
		return "GoogleCell"
	}
	
	var id = ""
	var sender = UIViewController()
	
	static let identifier = "GoogleCell"
	
	static func create(id: String, description: String) -> GoogleCell {
		let view : GoogleCell! = UIView.create(nib: "GoogleCell")
//		GoogleActivityFetcher.addObserver(view)
		let userDefaults = UserDefaults.standard
		let userName = userDefaults.object(forKey: "GoogleUserName")
		
		if let userName = userName as? String {
			view.descriptionValue.text = userName
			view.addSignOutButton()
		} else {
			view.googleSignInOutContainer.addSubview(view.signInButton)
		}

		view.id = id
		view.descriptionTitle.text = description
		view.instructionButton.setTitle(Text.Settings.descriptionInstructions, for: .normal)
		view.instructionButton.tintColor = themeHighlighted
		view.googleSignInOutContainer.backgroundColor = themeWhiteBlackBackground
		return view
	}
	
	var delegate: GoogleCellDelegate?
	
	
	
	private func addSignOutButton() {
		signOutButton = UIButton(frame: googleSignInOutContainer.bounds)
		signOutButton.setTitle(Text.Settings.googleSignOutButton, for: .normal)
		signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
		googleSignInOutContainer.addSubview(signOutButton)
	}
	
	@IBAction func instruction(_ sender: UIButton) {
		delegate?.showInstructions(cell: self)
	}
	
	
	@objc func signOut() {
		let userDefaults = UserDefaults.standard
		userDefaults.removeObject(forKey: "GoogleUserName")
		descriptionValue.text = ""
		signOutButton.removeFromSuperview()
		googleSignInOutContainer.addSubview(signInButton)
		GIDSignIn.sharedInstance().signOut()
	}
	
	
	
	// MARK: - Fetcher Delegates
	
	func requesterDidStart() {
	}
	
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		switch response {
		case .OK(let option):
			if option == .updated {
				signInButton.removeFromSuperview()
				descriptionValue.text = UserDefaults.standard.object(forKey: "GoogleUserName") as? String
				addSignOutButton()
			}
		default: return
		}
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
	

	
	
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
	
}
