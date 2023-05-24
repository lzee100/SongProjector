//
//  testUIApp.swift
//  testUI
//
//  Created by Leo van der Zee on 11/05/2023.
//

import SwiftUI
import UserNotifications
import CoreData
import Photos
import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import Network

@main
struct ChurchBeamApp: App {
    
    @StateObject var userAuth: UserAuthModel =  UserAuthModel()
    @StateObject var soundPlayer = SoundPlayer2()
    @StateObject var musicDownloadManager =  MusicDownloadManager()
    @State private var showApp = false
    @State private var showOnboarding = false
    @State private var handleFireStore: Any?
    
    init() {
        initializeFireStore()
        setApplicationIdentifier()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(uiColor: .whiteColor).ignoresSafeArea()
                ProgressView()
                    .tint(Color(uiColor: .blackColor))
            }
            .onAppear {
                handleFireStore = Auth.auth().addStateDidChangeListener { auth, user in
                    if auth.currentUser == nil {
                        try? ResetCoreDataUseCase().reset(completion: {
                            showOnboarding = auth.currentUser == nil
                            showApp = auth.currentUser != nil
                        })
                    } else {
                        showOnboarding = auth.currentUser == nil
                        showApp = auth.currentUser != nil
                    }
                }
            }
            .fullScreenCover(isPresented: $showApp) {
                TabViewUI()
                    .environmentObject(soundPlayer)
                    .environmentObject(musicDownloadManager)
            }
            .animation(.easeOut, value: showApp)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingViewUI()
            }
            .animation(.easeOut, value: showOnboarding)
        }
    }
    
    private func initializeFireStore() {
//        ChurchBeamConfiguration.environment = .production
//        ChurchBeamConfiguration.environment.loadGoogleFile()
        if UserDefaults.standard.integer(forKey: "config.environment") != 0 {
            ChurchBeamConfiguration.environment.loadGoogleFile()
        } else {
            switch AppConfiguration.mode {
            case .TestFlight, .AppStore:
                ChurchBeamConfiguration.environment = .production
            case .Debug:
                ChurchBeamConfiguration.environment = .dev
            }
            ChurchBeamConfiguration.environment.loadGoogleFile()
        }
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }
    
    private func setApplicationIdentifier() {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: ApplicationIdentifier) == nil {
            let UUID = NSUUID().uuidString
            userDefaults.set(UUID, forKey: ApplicationIdentifier)
        }
    }
}


class UserAuthModel: ObservableObject {
    
    @Published var givenName: String = ""
    @Published var profilePicUrl: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    init(){
        check()
    }
    
    func checkStatus(){
        if(GIDSignIn.sharedInstance.currentUser != nil){
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            let givenName = user.profile?.givenName
            let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
            self.givenName = givenName ?? ""
            self.profilePicUrl = profilePicUrl
            self.isLoggedIn = true
        }else{
            self.isLoggedIn = false
            self.givenName = "Not Logged In"
            self.profilePicUrl =  ""
        }
    }
    
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
    
    func signIn(){
        
       guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: []) { result, error in
            if let error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            self.checkStatus()
        }
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
}
