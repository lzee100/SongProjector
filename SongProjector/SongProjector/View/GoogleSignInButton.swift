//
//  GoogleSignInButton.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

@MainActor class GoogleLoginSignOutModel: ObservableObject {
    
    enum LoginErro: LocalizedError {
        case noLoginCredentials
        
        var errorDescription: String? {
            return "No login credentials found"
        }
    }
    
    @Published var error: LocalizedError?
    
    func signInWithGoogle() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}

         GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: ["https://www.googleapis.com/auth/calendar.events.public.readonly"]) { result, error in
             if let error {
                 self.error = RequestError.unknown(requester: "", error: error)
             }
             guard let user = result?.user,
               let idToken = user.idToken?.tokenString
             else {
                 self.error = LoginErro.noLoginCredentials
                 return
             }

             let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                            accessToken: user.accessToken.tokenString)
             Auth.auth().signIn(with: credential) { _, error in
                 if let error {
                     self.error = RequestError.unknown(requester: "", error: error)
                 }
             }
         }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.error = RequestError.unknown(requester: "", error: error)
        }
    }

}

struct GoogleButtonConfiguration: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding([.trailing], 10)
            .foregroundColor(.white)
            .background(
                Color(hex: "4285F4")
            )
            .cornerRadius(3)
    }
}

struct GoogleSignInButton: View {
    
    @ObservedObject var viewModel: GoogleLoginSignOutModel
    
    var body: some View {
        Button {
            viewModel.signInWithGoogle()
        } label: {
            HStack {
                Image("btn_google_dark_normal_ios")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 50)
                Text("Sign in with google")
            }
        }
        .buttonStyle(GoogleButtonConfiguration())
    }
}

struct GoogleLogoutButton: View {
    
    @ObservedObject var viewModel: GoogleLoginSignOutModel
    
    var body: some View {
        Button {
            viewModel.signOut()
        } label: {
            HStack {
                Image("btn_google_dark_normal_ios")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 50)
                Text("Sign out")
            }
        }
        .buttonStyle(GoogleButtonConfiguration())
    }
}


struct GoogleSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInButton(viewModel: GoogleLoginSignOutModel())
    }
}
