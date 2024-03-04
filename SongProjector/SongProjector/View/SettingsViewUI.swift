//
//  SettingsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import Combine

@MainActor class SettingsViewModel: ObservableObject {
    
    @Published var googleAgendaId: String = ""
    @Published var changedGoogleAgendaId: String = ""
    @Published var showingSaveGoogleAgendaIdButton = false
    @Published var showingSetMotherChurch = false
    @Published var showingSubscribeToBabyChurchesOfMotherChurchZwolle = false
    @Published var error: LocalizedError?
    
    @Published private(set) var user: UserCodable?
    @Published private(set) var showingLoader = false
    @Published private(set) var profilePictureData: Data?
    @Published private(set) var isLoading = false

    private(set) var userSubmitter: SubmitUseCase<UserCodable>?
    private(set) var anyCancellable: AnyCancellable?
    private(set) var submitUserTask: Task<(), Error>?


    var contentPackage: ContentPackage?
    
    let authentication = Auth.auth().currentUser

    func fetchUser() async {
        user = await GetUserUseCase().get()
        googleAgendaId = user?.googleCalendarId ?? ""
        changedGoogleAgendaId = googleAgendaId
    }
    
    func fetchUserRemotely() async {
        showingLoader = true
        do {
            _ = try await FetchUsersUseCase.fetch()
            await fetchUser()
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
    
    func set(_ contentPackage: ContentPackage) async {
        showingLoader = true
        await fetchUserRemotely()
        guard var user else {
            showingLoader = false
            return
        }
        user.contentPackage = contentPackage.rawValue
        if uploadSecret != nil {
            user.contentPackageBabyChurchesMotherChurch = nil
        }
        do {
            _ = try await SubmitUseCase(endpoint: .users, requestMethod: .put, uploadObjects: [user]).submit()
            await fetchUser()
            try await SyncUniversalCollectionsUseCase().request()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error.forcedLocalizedError
        }
    }
    
    func didSelectContentPackagePastorsZwolle() async {
        showingLoader = true
        await fetchUserRemotely()
        guard var user else {
            showingLoader = false
            return
        }
        user.contentPackageBabyChurchesMotherChurch = ContentPackage.pastorsZwolle.rawValue
        if uploadSecret != nil {
            user.contentPackage = nil
        }
        do {
            _ = try await SubmitUseCase(endpoint: .users, requestMethod: .put, uploadObjects: [user]).submit()
            await fetchUser()
            try await SyncUniversalCollectionsUseCase().request()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error.forcedLocalizedError
        }

    }

    func submitGoogleAgendaId() async {
        do {
            guard var user = user else { return }
            isLoading = true
            user.googleCalendarId = changedGoogleAgendaId.trimmingCharacters(in: .whitespacesAndNewlines)
            self.userSubmitter = SubmitUseCase(endpoint: .users, requestMethod: .put, uploadObjects: [user])
            try await self.userSubmitter?.submit()
            await self.fetchUserRemotely()
            isLoading = false
        } catch {
            isLoading = false
            self.error = error.forcedLocalizedError
        }
    }
}

struct SettingsViewUI: View {

    @Binding var selectedTab: Feature
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
                    if viewModel.showingSaveGoogleAgendaIdButton {
                        Button {
                            Task(priority: .userInitiated) {
                                await viewModel.submitGoogleAgendaId()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Label {
                                    Text(AppText.Actions.save)
                                } icon: {
                                    if viewModel.isLoading {
                                        ProgressView()
                                    } else {
                                        EmptyView()
                                    }
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(.white)
                        .tint(Color(uiColor: themeHighlighted))
                        .disabled(viewModel.isLoading)
                    }
                }

                Section(AppText.Settings.sectionMotherChurch) {
                    Text(AppText.Settings.motherChurchExplain)
                        .styleAs(font: .xNormal)
                        .padding(.bottom)
                    if let motherChurch = viewModel.user?.contentPackage, uploadSecret == nil {
                        Button {
                        } label: {
                            Text(motherChurch)
                        }
                        .disabled(true)
                    } else {
                        sectionMotherChurch
                    }
                }

                Section(AppText.Settings.sectionContentPackageBabyChurches) {
                    Text(AppText.Settings.sectionContentPackageBabyChurchesExplain)
                        .styleAs(font: .xNormal)
                    if let contentPackage = viewModel.user?.contentPackageBabyChurchesMotherChurch, uploadSecret == nil {
                        Button {
                        } label: {
                            Text(contentPackage)
                        }
                        .disabled(true)
                    } else {
                        contentPackagePastorsZwolleButton
                    }
                }
                //                Section(AppText.Settings.contactId) {
                //                    contactReferenceIDView
                //                }
                //
                Section(AppText.Settings.sectionAppSettings) {
                    resetInstrumentMutes
                }

#if DEBUG
                Section("Verwijder alle clusters") {
                    DeleteAllClustersSectionView()
                }

                Section("Omgeving") {
                    Text(ChurchBeamConfiguration.environment.name)
                        .styleAs(font: .xNormal)
                }
#endif
            }
            .onAppear {
                selectedTab = .settings
            }
            .task {
                await viewModel.fetchUserRemotely()
            }
            .alert(Text(AppText.Settings.motherChurchAreYouSure(viewModel.contentPackage ?? ContentPackage.zwolleDutch)), isPresented: $viewModel.showingSetMotherChurch, actions: {
                Button(role: .none) {
                    if let motherChurch = viewModel.contentPackage {
                        Task {
                            await viewModel.set(motherChurch)
                        }
                    }
                } label: {
                    Text(AppText.Actions.change)
                }
                Button(AppText.Actions.cancel, role: .cancel, action: {})
            })
            .alert(Text(AppText.Settings.sectionContentPackageBabyChurchesAreYouSure(ContentPackage.pastorsZwolle)), isPresented: $viewModel.showingSubscribeToBabyChurchesOfMotherChurchZwolle, actions: {
                Button(role: .none) {
                    Task {
                        await viewModel.didSelectContentPackagePastorsZwolle()
                    }
                } label: {
                    Text(AppText.Actions.change)
                }
                Button(AppText.Actions.cancel, role: .cancel, action: {})
            })
            .errorAlert(error: $viewModel.error)
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
            TextField(AppText.Settings.sectionCalendarId, text: $viewModel.changedGoogleAgendaId)
                .styleAs(font: .xNormal)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: viewModel.changedGoogleAgendaId) { oldValue, newValue in
                    viewModel.showingSaveGoogleAgendaIdButton = newValue != viewModel.googleAgendaId
                }
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
            viewModel.showingSetMotherChurch.toggle()
        } label: {
            Text(AppText.Settings.ResetMutes)
                .styleAs(font: .xNormal, color: Color(uiColor: themeHighlighted))
        }
    }
    
    @ViewBuilder var sectionMotherChurch: some View {
        VStack {
            ForEach(ContentPackage.zwolleContent) { church in
                motherChurchButton(church)
            }
        }
    }
    
    @ViewBuilder func motherChurchButton(_ contentPackage: ContentPackage) -> some View {
        Button {
            viewModel.contentPackage = contentPackage
            viewModel.showingSetMotherChurch.toggle()
        } label: {
            HStack {
                Spacer()
                Text(contentPackage.displayName)
                    .styleAs(font: .xNormal, color: .white)
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(uiColor: uploadSecret != nil && viewModel.user?.contentPackage == contentPackage.rawValue ? .red1 : themeHighlighted))
        .disabled((viewModel.showingLoader || viewModel.user?.contentPackage != nil) && (uploadSecret == nil))
    }
    
    @ViewBuilder var contentPackagePastorsZwolleButton: some View {
        Button {
            viewModel.showingSubscribeToBabyChurchesOfMotherChurchZwolle.toggle()
        } label: {
            HStack {
                Spacer()
                Text(AppText.Settings.subscribeTo + AppText.Settings.contentPackageZwolleChurches)
                    .styleAs(font: .xNormal, color: .white)
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(uiColor: uploadSecret != nil && viewModel.user?.contentPackageBabyChurchesMotherChurch != nil ? .red1 : themeHighlighted))
        .disabled((viewModel.showingLoader || viewModel.user?.contentPackageBabyChurchesMotherChurch != nil) && (uploadSecret == nil))
    }

    private struct DeleteAllClustersSectionView: View {
        @State private var userUID = ""
        var body: some View {
            VStack {
                TextField("User uid", text: $userUID)
                Button {
                    guard userUID != "" else { return }
                    Task {
                        do {
                            try await DeleteAllClustersSubmitter().request(userUID: userUID)
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Delete all clusters")
                }
            }
        }
    }

}

struct SettingsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SettingsViewUI(selectedTab: .constant(.songService))
    }
}
