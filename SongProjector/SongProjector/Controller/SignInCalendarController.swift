//
//  SignInCalendarController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInCalendarController: UIViewController {

    static let identifier = "SignInCalendarController"
    static let nav = "SignInCalendarNavController"

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var singInButtonContainer: UIView!
    @IBOutlet var closeButton: UIBarButtonItem!
    
    let signInButton = GIDSignInButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.title = AppText.Actions.close
        title = AppText.SingInGoogleController.title
        infoLabel.text = AppText.SingInGoogleController.infoText
        GIDSignIn.sharedInstance()?.presentingViewController = self
        singInButtonContainer.addSubview(signInButton)
        
        NotificationCenter.default.addObserver(forName: .authenticatedGoogle, object: nil, queue: .main) { [weak self] (_) in
            self?.dismiss(animated: true)
        }
        
    }
    

  

    @IBAction func didPressClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
