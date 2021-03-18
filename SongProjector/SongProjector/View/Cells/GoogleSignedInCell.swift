//
//  GoogleSignedInCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

protocol GoogleSignedInCellDelegate {
	func didSignedOut()
}

class GoogleSignedInCell: ChurchBeamCell {

	static let identifier = "GoogleSignedInCell"
	@IBOutlet var profilePictureImageView: ChurchBeamImageView!
	@IBOutlet var usernameLabel: UILabel!
	@IBOutlet var emailLabel: UILabel!
	@IBOutlet var signOutContainerView: UIView!
    @IBOutlet var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageToUserNameConstraint: NSLayoutConstraint!
    
	let signInButton = GIDSignInButton()
	var sender = UIViewController()
	@IBOutlet var signOutButton: UIButton!
	var delegate: GoogleSignedInCellDelegate?
	static let preferredHeight : CGFloat = 150
	
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePictureImageView.cornerRadius = profilePictureImageView.bounds.height / 2
        signOutContainerView.layer.cornerRadius = 6
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
		signOutButton.setTitle(AppText.Settings.googleSignOutButton, for: .normal)
    }
	
	@objc func signOut() {
		signOutButton.removeFromSuperview()
		signOutContainerView.addSubview(signInButton)
		GIDSignIn.sharedInstance().signOut()
	}
	
	func setup(delegate: GoogleSignedInCellDelegate, sender: UIViewController) {
        if let user = Auth.auth().currentUser {
            if let url = user.photoURL {
                profilePictureImageView.url = user.photoURL
                imageWidthConstraint.constant = 50
                imageToUserNameConstraint.constant = 8
            } else {
                imageWidthConstraint.constant = 0
                imageToUserNameConstraint.constant = 0
            }
            emailLabel.text = user.email
            usernameLabel.text = user.displayName
        }
        
		self.sender = sender
		GIDSignIn.sharedInstance()?.presentingViewController = sender
	}
	
	
	// MARK: Google Fetcher Delegates
	
	func loginDidFailWithError(message: String) {
		let alert = UIAlertController(title: AppText.Settings.errorTitleGoogleAuth, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: AppText.Actions.ok, style: .default, handler: nil))
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
            GoogleActivityFetcher.fetch(force: true)
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
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        GIDSignIn.sharedInstance()?.signOut()
        NotificationCenter.default.post(name: .checkAuthentication, object: nil)
    }
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


class ChurchBeamImageView: UIImageView {
    
    
    var url: URL? {
        didSet {
            update()
        }
    }
    
    var cornerRadius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }
    
    
    private func update() {
        guard let url = url else { return }
        contentMode = .scaleAspectFill
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                
                return
            }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
        
        
    }
}
