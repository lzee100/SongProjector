//
//  SignInCalendarController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import SwiftUI

class SignInCalendarController: UIViewController {

    static let identifier = "SignInCalendarController"
    static let nav = "SignInCalendarNavController"

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var singInButtonContainer: UIView!
    @IBOutlet var closeButton: UIBarButtonItem!
    
    lazy var signInButton: GoogleSignInSwift.GoogleSignInButton = {
        GoogleSignInSwift.GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(), action: handleSignInButton)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.title = AppText.Actions.close
        title = AppText.SingInGoogleController.title
        infoLabel.text = AppText.SingInGoogleController.infoText
        singInButtonContainer.addSubview(UIHostingController(rootView: signInButton).view)
        NotificationCenter.default.addObserver(forName: .authenticatedGoogle, object: nil, queue: .main) { [weak self] (_) in
            self?.dismiss(animated: true)
        }
        
    }
    
    func handleSignInButton() {
      GIDSignIn.sharedInstance.signIn(
        withPresenting: self) { [weak self] signInResult, error in
            guard signInResult != nil else {
              let controller = UIAlertController(title: AppText.Generic.loginError, message: error?.localizedDescription, preferredStyle: .alert)
              controller.addAction(UIAlertAction(title: AppText.Actions.ok, style: .default))
              self?.present(controller, animated: true)
            return
          }
            guard let token = signInResult?.user.idToken?.tokenString, let accessToken = signInResult?.user.accessToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: token, accessToken: accessToken.tokenString)
            
            if let email = Auth.auth().currentUser?.email {
                UserDefaults.standard.set(email, forKey: GoogleMail)
            }
            NotificationCenter.default.post(Notification(name: .checkAuthentication))
            NotificationCenter.default.post(name: .authenticatedGoogle, object: credential)
          self?.dismiss(animated: true)
        }
    }

    @IBAction func didPressClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
