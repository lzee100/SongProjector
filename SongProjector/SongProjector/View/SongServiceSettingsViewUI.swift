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

    func fetchSettings() async {
        let settings = await GetSongServiceSettingsUseCase().fetch()
        print(settings)
        songServiceSettings = settings
//        songServiceSettings = await GetSongServiceSettingsUseCase().fetch()
    }
    
    func fetchRemoteSettings() async {
        isLoading = true
        await fetchSettings()
        do {
            let result = try await FetchSongServiceSettingsUseCase().fetch()
            if result.count > 0 {
                await fetchSettings()
            }
            isLoading = false
        } catch {
            isLoading = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
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
                            tagsListView(section: section)
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
                await viewModel.fetchRemoteSettings()
            }
            .navigationTitle(AppText.SongServiceManagement.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        switch viewModel.editBarButton {
                        case .new:
                            self.showingSongServiceSettingsEditorView = .makeDefault()
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
                Task {
                    await viewModel.fetchSettings()
                }
            }, content: { settings in
                SongServiceSettingsEditorViewUI(
                    showingSongServiceSettings: $showingSongServiceSettingsEditorView,
                    viewModel: SongServiceSettingsEditorViewModel(songServiceSettings: settings)
                )
            })
        }
    }
    
    @ViewBuilder func tagsListView(section: SongServiceSectionCodable) -> some View {
        ForEach(section.tags) { tag in
            tagView(title: tag.title ?? "", isPinned: tag.isPinned)
        }
    }
    
    @ViewBuilder func tagView(title: String, isPinned: Bool) -> some View {
        HStack(spacing: 10) {
            Button() {
            } label: {
                HStack {
                    Text(title)
                    if isPinned {
                        Image(systemName: "pin.fill")
                    }
                }
            }
            .styleAsSelectionCapsuleButton(isSelected: false)
            .disabled(true)
            Spacer()
        }
    }
}

struct SongServiceSettingsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SongServiceSettingsViewUI()
    }
}
