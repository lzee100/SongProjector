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
    
    @Published var googleAgendaId: String = ""
    
    @Published private(set) var user: UserCodable?
    @Published private(set) var error: LocalizedError?
    @Published private(set) var showingLoader = false
    @Published private(set) var profilePictureData: Data?

    let authentication = Auth.auth().currentUser

    func fetchUser() {
        let users: [User] = DataFetcher().getEntities(moc: moc)
        self.user = users.compactMap { UserCodable(managedObject: $0, context: moc) }.first
        if let googleAgendaId = user?.googleCalendarId {
            self.googleAgendaId = googleAgendaId
        }
    }
    
    func fetchUserRemotely() async {
        showingLoader = true
        do {
            let result = try await FetchUsersUseCase.fetch()
            switch result {
            case .failed(let error): self.error = error
            case .succes(let users): saveLocally(users)
            }
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
    
    func resetMutes() {
        MuteInstrumentsUseCase().resetMutes {
        }
    }
    
    private func saveLocally(_ entities: [UserCodable]) {
        ManagedObjectContextHandler<UserCodable>().save(entities: entities, completion: { [weak self] _ in
            self?.fetchUser()
            self?.showingLoader = false
        })
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
                
                Section(AppText.Settings.sectionCalendarId) {
                    googleAgendaIdView
                }
                
                Section(AppText.Settings.sectionAppSettings) {
                    resetInstrumentMutes
                }
            }
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
    
    @ViewBuilder var googleAgendaIdView: some View {
        VStack {
            TextField(AppText.Settings.sectionCalendarId, text: $viewModel.googleAgendaId)
                .styleAs(font: .xNormal)
                .textFieldStyle(.roundedBorder)
                .padding()
        }
    }
    
    @ViewBuilder var resetInstrumentMutes: some View {
        Button {
            viewModel.resetMutes()
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
