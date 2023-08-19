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
    @Published var showingSetRegio = false
    
    @Published private(set) var user: UserCodable?
    @Published private(set) var error: LocalizedError?
    @Published private(set) var showingLoader = false
    @Published private(set) var profilePictureData: Data?
    var motherChurch: MotherChurch?
    
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
    
    func resetMutes() async {
        await MuteInstrumentsUseCase.resetMutes()
    }
    
    func set(_ motherChurch: MotherChurch) async {
        guard var user = await GetUserUseCase().get() else { return }
        user.motherChurch = motherChurch.rawValue
        do {
            showingLoader = true
            let result = try await SubmitUseCase(endpoint: .users, requestMethod: .put, uploadObjects: [user]).submit()
            await fetchUser()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error.forcedLocalizedError
        }
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
                
                Section(AppText.Settings.sectionRegion) {
                    if let region = viewModel.user?.motherChurch {
                        Button {
                        } label: {
                            Text(region)
                        }
                        .disabled(true)
                    } else {
                        sectionRegion
                    }
                }
                
//                Section(AppText.Settings.contactId) {
//                    contactReferenceIDView
//                }
//
                Section(AppText.Settings.sectionAppSettings) {
                    resetInstrumentMutes
                }
            }
            .alert(Text(AppText.Settings.motherChurchAreYouSure(viewModel.motherChurch ?? MotherChurch.zwolleDutch)), isPresented: $viewModel.showingSetRegio, presenting: nil, actions: {
                Button {
                    if let motherChurch = viewModel.motherChurch {
                        Task {
                            await viewModel.set(motherChurch)
                        }
                    }
                } label: {
                    Text(AppText.Actions.change)
                }
                Button(AppText.Actions.cancel, role: .cancel, action: {})
            })
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
            viewModel.showingSetRegio.toggle()
        } label: {
            Text(AppText.Settings.ResetMutes)
                .styleAs(font: .xNormal, color: Color(uiColor: themeHighlighted))
        }
    }
    
    @ViewBuilder var sectionRegion: some View {
        VStack {
            Text(AppText.Settings.motherChurchExplain)
                .styleAs(font: .xNormal)
                .padding(.bottom)
            ForEach(MotherChurch.allCases) { church in
                motherChurchButton(church)
            }
        }
    }
    
    @ViewBuilder func motherChurchButton(_ motherChurch: MotherChurch) -> some View {
        Button {
            viewModel.motherChurch = motherChurch
            viewModel.showingSetRegio.toggle()
        } label: {
            Text(motherChurch.displayName)
        }
        .disabled(viewModel.showingLoader && viewModel.user?.motherChurch != nil)
    }
    
}

struct SettingsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SettingsViewUI()
    }
}
