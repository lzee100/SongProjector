//
//  IntroPageController22.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import AuthenticationServices
import CryptoKit

// https://firebase.google.com/docs/auth/ios/apple?authuser=2

class IntroPageController22: PageController {
   
    
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var loginStackView: UIStackView!
    @IBOutlet var containerViewHeightConstraint: NSLayoutConstraint!
    
    static let identifier = "IntroPageController22"
    fileprivate var currentNonce: String?

    override var requesters: [RequesterBase] {
        return [UserFetcher]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.scopes = ["https://www.googleapis.com/auth/calendar.readonly", "https://www.googleapis.com/auth/calendar.events.readonly"]
        descriptionTextView.font = .xNormal
        descriptionTextView.textColor = .blackColor
        descriptionTextView.text = AppText.Intro.loginWithChurchGoogle
        descriptionTextView.noPadding()
        
        let googleLogin = GIDSignInButton(frame: .zero)
        googleLogin.translatesAutoresizingMaskIntoConstraints = false
        
        let appleLogin = ASAuthorizationAppleIDButton()
        appleLogin.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        [googleLogin, appleLogin].forEach({ loginStackView.addArrangedSubview($0) })
        view.layoutIfNeeded()
        let textHeight = descriptionTextView.text.height(withConstrainedWidth: descriptionTextView.bounds.width, font: descriptionTextView.font!) + 10
        let buttons = CGFloat(120)
        let maxHeight = min(buttons + 20 + textHeight, view.bounds.height * 0.8)
        containerViewHeightConstraint.constant = maxHeight
//        performExistingAccountSetupFlows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: .authenticatedGoogle, object: nil, queue: .main) { [weak self] (notification) in
            if let autcred = notification.object as? AuthCredential {
                self?.signInToFirebase(credential: autcred)
            }
        }
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    @objc private func handleAuthorizationAppleIDButtonPress() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

    }
    
    private func performExistingAccountSetupFlows() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        // Prepare requests for both Apple ID and password providers.
        let requests = [request, ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    
    private func signInToFirebase(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in (resolver.hints) {
                        displayNameString += tmpFactorInfo.displayName ?? ""
                        displayNameString += " "
                    }
                    self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)", completionBlock: { userPressedOK, displayName in
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                            if (displayName == tmpFactorInfo.displayName) {
                                selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                            }
                        }
                        PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                            if error != nil {
                                print("Multi factor start sign in failed. Error: \(error.debugDescription)")
                            } else {
                                self.showTextInputPrompt(withMessage: "Verification code for \(selectedHint?.displayName ?? "")", completionBlock: { userPressedOK, verificationCode in
                                    let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode!)
                                    let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                                    resolver.resolveSignIn(with: assertion!) { authResult, error in
                                        if error != nil {
                                            print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                                        } else {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                })
                            }
                        }
                    })
                } else {
                    self.showMessagePrompt(error.localizedDescription)
                    return
                }
                
                return
            }
         
            DispatchQueue.main.async {
                self.fetchUser()
            }
        }
        
    }
    
    override func handleRequestFinish(requesterId: String, result: Any?) {
        switch requesterId {
        case UserFetcher.id: submitUser()
        default: break
        }
    }
    
    private func showMessagePrompt(_ message: String) {

    }
    
    private func showTextInputPrompt(withMessage: String, completionBlock: (String, String?) -> Void) {

    }
    
    private func fetchUser() {
        let entities: [Entity] = DataFetcher().getEntities(moc: moc)
        entities.forEach({ moc.delete($0) })
        do {
            try moc.save()
        } catch { }
        UserFetcher.fetch()
    }
    
    private func submitUser() {
        NotificationCenter.default.post(name: .newUser, object: nil)
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    
}

extension IntroPageController22: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

extension IntroPageController22: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Queues.main.async {
            self.show(message: error.localizedDescription)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
            // Error. If error.code == .MissingOrInvalidNonce, make sure
            // you're sending the SHA256-hashed nonce as a hex string with
            // your request to Apple.
            Queues.main.async {
                self.show(message: AppText.Intro.errorLoginApple(error: error))
            }
            return
          }
            
            DispatchQueue.main.async {
                self.fetchUser()
            }
            
        }
      }
    }


}
