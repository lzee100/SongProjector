//
//  testUIApp.swift
//  testUI
//
//  Created by Leo van der Zee on 11/05/2023.
//

import CoreData
import Firebase
import FirebaseAuth
import GoogleSignIn
import Network
import Photos
import SwiftUI
import UIKit
import UserNotifications

class Authentication: ObservableObject {
    @Published var isRegistered = false
}

var store = ExternalDisplayConnector()

struct ChurchBeamApp: View {
    enum AppState: Identifiable {
        var id: String {
            UUID().uuidString
        }

        case onboarding
        case app
    }

    let store: ExternalDisplayConnector
    @SwiftUI.Environment(\.scenePhase) private var scenePhase

    var userAuth: UserAuthModel = .init()
    @StateObject var soundPlayer = SoundPlayer2()
    @StateObject var subscriptionsStore = SubscriptionsStore()
    @StateObject var musicDownloadManager = MusicDownloadManager()
    @StateObject private var authentication = Authentication()
    @StateObject var universalClusterRequester = SyncUniversalCollectionsUseCase()
    @State private var appState: AppState? = nil
    @State private var showApp = false
    @State private var showOnboarding = false
    @State private var handleFireStore: Any?
    @State private var showingUniversalClusterError = false
    @State private var showingPreparingAccount = false
    @State private var showingFetchingAdminUserChurch = false
    @State private var fetchSubscriptionsTask: Task<(), Never>?

    init(store: ExternalDisplayConnector) {
        self.store = store
        initializeFireStore()
        initializeLocalStorage()
        initializeCoreData()
        setApplicationIdentifier()
        setupApplicationIdentifier()
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .blackColor).ignoresSafeArea()
            ProgressView()
                .tint(Color(uiColor: .whiteColor))
            if showingPreparingAccount {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 30) {
                            Text(AppText.Start.syncingAccountData)
                                .styleAs(font: .title, color: .white)
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.4)
                        }
                        .padding(EdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40))
                        .background(Color(uiColor: themeHighlighted))
                        .cornerRadius(20)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .environmentObject(subscriptionsStore)
        .onAppear {
            handleFireStore = Auth.auth().addStateDidChangeListener { auth, _ in
                authentication.isRegistered = auth.currentUser != nil
                
                if !authentication.isRegistered {
                    UserDefaults.standard.removeObject(forKey: secretKey)
                    Task {
                        try? await ResetCoreDataUseCase().reset()
                    }
                }
                Task {
                    if !showOnboarding, !showApp {
                        Task {
                            do {
                                await getAdminUserAndChurch()
                                try await syncAccountDataIfNeeded()
                                showOnboarding = !authentication.isRegistered
                                showApp = authentication.isRegistered
                                handleTransition()
                            } catch {
                                showingFetchingAdminUserChurch = true
                            }
                        }
                    } else {
                        handleTransition()
                    }
                }
            }
        }
        .onChange(of: scenePhase, { oldValue, newValue in
            switch newValue {
            case .active: sceneWillEnterForeground()
            case .inactive, .background: sceneWillResignActive()
            @unknown default: return
            }
        })
        .alert(isPresented: $showingFetchingAdminUserChurch, content: {
            Alert(title: Text("Er ging iets mis met het ophalen van de data voor het account"), message: nil, dismissButton: .cancel())
        })
        .alert(isPresented: $showingUniversalClusterError, content: {
            Alert(title: Text("Er ging iets mis met het krijgen van de data"), message: nil, dismissButton: .cancel())
        })
        .fullScreenCover(isPresented: $showApp, onDismiss: {
            showOnboarding = !authentication.isRegistered
            handleTransition()
        }, content: {
            TabViewUI()
                .environmentObject(soundPlayer)
                .environmentObject(musicDownloadManager)
                .environmentObject(store)
                .environmentObject(universalClusterRequester)
                .environmentObject(subscriptionsStore)
        })
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            Task {
                do {
                    try await syncAccountDataIfNeeded()
                    showApp = authentication.isRegistered
                    handleTransition()
                } catch {
                    showingFetchingAdminUserChurch = true
                }
            }
        }, content: {
            OnboardingViewUI()
        })
    }
        
    private func handleTransition() {
        if showOnboarding {
            showOnboarding = !authentication.isRegistered
            appState = showOnboarding ? .onboarding : .app
        } else {
            showApp = authentication.isRegistered
            appState = showApp ? .app : .onboarding
        }
    }
    
    private func syncAccountDataIfNeeded() async throws {
        guard authentication.isRegistered else { return }
        await getAdminUserAndChurch()
        let admin = await GetAdminUseCase().get()
        guard admin == nil else { return }
        
        do {
            showingPreparingAccount = true
            try await universalClusterRequester.request()
            showingPreparingAccount = false
        } catch {
            showingUniversalClusterError = true
        }
    }
    
    private func getChurch() async throws {
        _ = try await FetchUseCaseAsync<ChurchCodable, Church>(endpoint: .churches).fetch()
    }
    
    private func getUser() async throws {
        guard let appInstallTokenId = UserDefaults.standard.string(forKey: ApplicationIdentifier) else { return }
        _ = try await FetchUserUseCase().fetch(installTokenId: appInstallTokenId)
    }
    
    private func getAdmin() async throws {
        _ = try await FetchUseCaseAsync<AdminCodable, Admin>(endpoint: .admin).fetch()
        if await GetAdminUseCase().get() != nil {
            UserDefaults.standard.set("true", forKey: secretKey)
        }
    }
    
    private func getAdminUserAndChurch() async {
        await withThrowingTaskGroup(of: Void.self) { group in
            for item in 0 ..< 3 {
                group.addTask {
                    switch item {
                    case 0: try await getChurch()
                    case 1: try await getUser()
                    default: try await getAdmin()
                    }
                }
            }
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
    
    private func initializeLocalStorage() {
        CreateChurchBeamDirectoryUseCase().setup()
    }
    
    private func initializeCoreData() {
        Store.setup()
    }
    
    private func setupApplicationIdentifier() {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: ApplicationIdentifier) == nil {
            let UUID = NSUUID().uuidString
            userDefaults.set(UUID, forKey: ApplicationIdentifier)
        }
    }

    private func sceneWillEnterForeground() {
        fetchSubscriptionsTask = Task {
            await subscriptionsStore.fetchActiveTransactions()
        }
    }

    private func sceneWillResignActive() {
        fetchSubscriptionsTask?.cancel()
    }

}

class UserAuthModel: ObservableObject {
    @Published var givenName: String = ""
    @Published var profilePicUrl: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    init() {
        check()
    }
    
    func checkStatus() {
        if GIDSignIn.sharedInstance.currentUser != nil {
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            let givenName = user.profile?.givenName
            let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
            self.givenName = givenName ?? ""
            self.profilePicUrl = profilePicUrl
            isLoggedIn = true
        } else {
            isLoggedIn = false
            givenName = "Not Logged In"
            profilePicUrl = ""
        }
    }
    
    func check() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { _, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
    
    func signIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: []) { _, error in
            if let error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            self.checkStatus()
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        checkStatus()
    }
}
