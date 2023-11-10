//
//  SettingsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import FirebaseAuth

@MainActor class SettingsViewModel: ObservableObject {
    
    @EnvironmentObject private var subscriptionsStore: SubscriptionsStore
    @Published var googleAgendaId: String = ""
    
    @Published private(set) var user: UserCodable?
    @Published private(set) var error: LocalizedError?
    @Published private(set) var showingLoader = false
    @Published private(set) var profilePictureData: Data?
    @Published var showingSubscriptions = false

    let authentication = Auth.auth().currentUser

    func fetchUser() async {
        user = await GetUserUseCase().get()
        googleAgendaId = user?.googleCalendarId ?? ""
    }
    
    func fetchUserRemotely() async {
        showingLoader = true
        do {
            let result = try await FetchUsersUseCase.fetch()
            self.user = result.first
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func fetchProfileImage(url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.profilePictureData = data
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func showSubscriptions() {
        showingSubscriptions.toggle()
    }
    
    func resetMutes() async {
        await MuteInstrumentsUseCase.resetMutes()
    }
}

struct SettingsViewUI: View {
    
    @StateObject private var singInOutViewModel = GoogleLoginSignOutModel()
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                if let user = viewModel.authentication {
                    Section(AppText.Settings.sectionGmailAccount) {
                        credentialsView(user: user)
                    }
                }
                
//                if let id = viewModel.user?.productId, !id.isBlanc {
                    Section(AppText.Settings.sectionManageSubscriptions) {
                        subscriptionsButtonView
                    }
//                }
                
//                Section(AppText.Settings.sectionCalendarId) {
//                    googleAgendaIdView
//                }
                
//                Section(AppText.Settings.contactId) {
//                    contactReferenceIDView
//                }
//
                Section(AppText.Settings.sectionAppSettings) {
                    resetInstrumentMutes
                }
            }
            .manageSubscriptionsSheet(isPresented: $viewModel.showingSubscriptions)
        }
    }
    
    @ViewBuilder private func credentialsView(user: FirebaseAuth.User) -> some View {
        VStack {
            HStack(spacing: 10) {
                if let data = viewModel.profilePictureData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                }
                VStack {
                    if let name = user.displayName {
                        Text(name)
                    }
                    if let email = user.email {
                        Text(email)
                    }
                }
                .styleAs(font: .xNormal)
            }
            GoogleLogoutButton(viewModel: singInOutViewModel)
        }
        .task {
            if let photoUrl = user.photoURL {
                await viewModel.fetchProfileImage(url: photoUrl)
            }
        }
    }
    
    @ViewBuilder var subscriptionsButtonView: some View {
        Button {
            viewModel.showSubscriptions()
        } label: {
            Text(AppText.Settings.sectionManageSubscriptions)
                .styleAs(font: .xNormal, color: Color(uiColor: themeHighlighted))
        }

    }

    @ViewBuilder var googleAgendaIdView: some View {
        VStack {
            TextField(AppText.Settings.sectionCalendarId, text: $viewModel.googleAgendaId)
                .styleAs(font: .xNormal)
                .textFieldStyle(.roundedBorder)
                .padding()
        }
    }
    
//    @ViewBuilder var contactReferenceIDView: some View {
//        VStack {
//            Text(viewModel.authentication?.uid ?? "-")
//                .styleAs(font: .xNormal)
//                .textFieldStyle(.roundedBorder)
//                .padding()
//        }
//    }
//
    @ViewBuilder var resetInstrumentMutes: some View {
        Button {
            Task {
                await viewModel.resetMutes()
            }
        } label: {
            Text(AppText.Settings.ResetMutes)
                .styleAs(font: .xNormal, color: Color(uiColor: themeHighlighted))
        }
    }
    
}

struct SettingsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SettingsViewUI()
    }
}
