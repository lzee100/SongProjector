//
//  OnboardingLoginViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import _AuthenticationServices_SwiftUI
import GoogleSignIn
import FirebaseAuth

struct OnboardingLoginViewUI: View {
    
    @StateObject private var viewModel = GoogleLoginSignOutModel()
    @State private var appleLoginError: LocalizedError?

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 40) {
                
                Text(AppText.Intro.loginWithChurchGoogle)
                    .lineLimit(nil)
                    .padding([.bottom], 3)
                    .padding([.top], 80)
                    .styleAs(font: .xLargeLight, color: .white)
                
                GoogleSignInButton(viewModel: viewModel)
                signUpWithAppleButton
                
            }
            .padding([.leading, .trailing], 50)
        }
        .errorAlert(error: $viewModel.error)
        .errorAlert(error: $appleLoginError)
    }
    
    @ViewBuilder var signUpWithAppleButton: some View {
        
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [ASAuthorization.Scope.fullName, ASAuthorization.Scope.email]
        } onCompletion: { result in
            switch result {
                case .success(let authorization):
                switch authorization.credential {
                  case let appleIdCredential as ASAuthorizationAppleIDCredential:
                    print("\n ** ASAuthorizationAppleIDCredential - \(#function)** \n")
                    print(appleIdCredential.email ?? "Email not available.")
                    print(appleIdCredential.fullName ?? "fullname not available")
                    print(appleIdCredential.fullName?.givenName ?? "givenName not available")
                    print(appleIdCredential.fullName?.familyName ?? "Familyname not available")
                    print(appleIdCredential.user)  // This is a user identifier
                    print(appleIdCredential.identityToken?.base64EncodedString() ?? "Identity token not available") //JWT Token
                    print(appleIdCredential.authorizationCode?.base64EncodedString() ?? "Authorization code not available")
                    
                    guard let data = appleIdCredential.identityToken, let accData = appleIdCredential.authorizationCode else {
                        return
                    }
                    let token = String(data: data, encoding: .utf8)
                    let accToken = String(data: accData, encoding: .utf8)

                    let credentials = OAuthProvider.credential(withProviderID: "apple.com", idToken: token ?? "", accessToken: accToken ?? "")
                    Auth.auth().signIn(with: credentials) { _, error in
                        if let error {
                            self.appleLoginError = RequestError.unknown(requester: "", error: error)
                        }
                    }
                    break
                    
                  default:
                    break
                }
                case .failure(let error):
                    print("Authorisation failed: \(error.localizedDescription)")
            }
        }
        .frame(width: 250, height: 50)
        .signInWithAppleButtonStyle(.white)
    }
    
    private func signInAtGoogle(identityToken: String, accessToken: String) {
        let credential = GoogleAuthProvider.credential(withIDToken: identityToken,
                                                       accessToken: accessToken)
        Auth.auth().signIn(with: credential) { _, error in
            if let error {
                self.appleLoginError = RequestError.unknown(requester: "", error: error)
            }
        }

    }

}

struct OnboardingLoginViewUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLoginViewUI()
    }
}
