//
//  SongServiceSettingsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class SongServiceSettingsViewModel: ObservableObject {
    
    @Published private(set) var songServiceSettings: SongServiceSettingsCodable?
    @Published private(set) var isLoading = false
    @Published var error: LocalizedError?
    
    enum EditButton {
        case new
        case edit(SongServiceSettingsCodable)
        
        @ViewBuilder var image: some View {
            switch self {
            case .new: Image(systemName: "plus").tint(Color(uiColor: themeHighlighted))
            case .edit: Text(AppText.Actions.edit).tint(Color(uiColor: themeHighlighted))
            }
        }
    }
    
    var editBarButton: EditButton {
        if let songServiceSettings {
            return .edit(songServiceSettings)
        }
        return .new
    }

    func fetchSettings() {
        let settings: [SongServiceSettings] = DataFetcher().getEntities(moc: moc)
        songServiceSettings = settings.compactMap { SongServiceSettingsCodable(managedObject: $0, context: moc)}.first
    }
    
    func fetchRemoteSettings() async {
        isLoading = true
        fetchSettings()
        do {
            let result = try await FetchSongServiceSettingsUseCase.fetch()
            switch result {
            case .failed(let error):
                self.error = error
            case .succes(let settings):
                saveLocally(settings)
            }
            fetchSettings()
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    private func saveLocally(_ entities: [SongServiceSettingsCodable]) {
        ManagedObjectContextHandler<SongServiceSettingsCodable>().save(entities: entities, completion: { [weak self] _ in
            self?.fetchSettings()
            self?.isLoading = false
        })
    }

}

struct SongServiceSettingsViewUI: View {
    
    @StateObject private var viewModel = SongServiceSettingsViewModel()
    @State private var showingSongServiceSettingsEditorView: SongServiceSettingsCodable?
    @State private var showingNewSongServiceSettingsView = false

    var body: some View {
        NavigationStack {
            Form {
                ForEach(viewModel.songServiceSettings?.sections ?? []) { section in
                    Section(section.title ?? "") {
                        Text("\(AppText.SongServiceManagement.numberOfSongs)\(section.numberOfSongs.intValue)")
                            .styleAs(font: .xNormal)
                        VStack(alignment: .leading) {
                            Text(AppText.Tags.title)
                                .styleAs(font: .xNormalBold)
                            Text(section.hasTags(moc: moc).compactMap { $0.title }.joined(separator: ", "))
                                .styleAs(font: .xNormal)
                        }
                    }
                }
            }
            .blur(radius: viewModel.isLoading ? 5 : 0)
            .allowsHitTesting(!viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .task {
                let settings: [SongServiceSettings] = DataFetcher().getEntities(moc: moc)
                if let settings = settings.first {
                    moc.delete(settings)
                    try? moc.save()
                }
                
                await viewModel.fetchRemoteSettings()
            }
            .navigationTitle(AppText.SongServiceManagement.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        switch viewModel.editBarButton {
                        case .new:
                            showingNewSongServiceSettingsView.toggle()
                        case .edit(let settings):
                            self.showingSongServiceSettingsEditorView = settings
                        }
                    } label: {
                        viewModel.editBarButton.image
                    }
                    .allowsHitTesting(!viewModel.isLoading)
                }
            }
            .errorAlert(error: $viewModel.error)
            .sheet(item: $showingSongServiceSettingsEditorView, onDismiss: {
                viewModel.fetchSettings()
            }, content: { settings in
                SongServiceSettingsEditorViewUI(
                    showingSongServiceSettings: $showingSongServiceSettingsEditorView,
                    viewModel: SongServiceSettingsEditorViewModel(songServiceSettings: settings)
                )
            })
            .sheet(isPresented: $showingNewSongServiceSettingsView) {
                viewModel.fetchSettings()
            } content: {
                NewSongServiceSettingsViewUI(showingNewSongServiceSettingsView: $showingNewSongServiceSettingsView)
            }

        }
    }
}

struct SongServiceSettingsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SongServiceSettingsViewUI()
    }
}
