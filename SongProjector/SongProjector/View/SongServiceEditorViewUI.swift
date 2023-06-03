//
//  SongServiceEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

protocol SongServiceEditorViewDelegate {
    func didSelect(collection: ClusterCodable)
}

@MainActor class SongServiceEditorModel: ObservableObject {
    
    enum EditButtons: String, Identifiable {
        var id: String {
            return self.rawValue
        }
        
        case add
        case generateSongService
        case delete
        case share
    }
    
    @Published private(set) var customSelectedSongs: [ClusterCodable] = []
    @Published private(set) var sectionedSongs: [SongServiceSectionWithSongs] = []
    @Published private(set) var songServiceSettings: SongServiceSettingsCodable? = nil
    @Published private(set) var showingLoader = false
    @Published var error: LocalizedError? = nil
    var isInUsage = false
    
    init(songServiceUI: SongServiceUI) {
        isInUsage = true
        guard songServiceUI.songs.count > 0 else { return }
        
        defer {
            Task {
                if let songServiceSettingsCodable = await GetSongServiceSettingsUseCase().fetch(), songServiceUI.sectionedSongs.count > 1 {
                    self.songServiceSettings = songServiceSettingsCodable
                    if songServiceUI.sectionedSongs.count == 1 {
                        customSelectedSongs = songServiceUI.sectionedSongs.flatMap { $0.songs }.map { $0.cluster }
                    } else {
                        sectionedSongs = songServiceUI.sectionedSongs
                    }
                } else if songServiceUI.sectionedSongs.count == 1 {
                    customSelectedSongs = songServiceUI.songs.map { $0.cluster }
                }
            }
        }
    }
    
    init() {
    }
    
    var editButtons: [EditButtons] {
       if songServiceSettings == nil, customSelectedSongs.count == 0 {
           return [.generateSongService, .add]
       } else if songServiceSettings != nil {
           return [.share, .delete]
       } else {
           return [.share, .delete, .add]
       }
   }
    
    func reset() {
        songServiceSettings = nil
        customSelectedSongs = []
        sectionedSongs = []
    }
    
    func fetchSongServiceSettingsRemotely() async {
        guard !showingLoader else { return }
        showingLoader = true
        do {
            let result = try await FetchSongServiceSettingsUseCase().fetch()
            await setFirstSongServiceSettings()
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func setFirstSongServiceSettings() async {
        songServiceSettings = await GetSongServiceSettingsUseCase().fetch()
        guard songServiceSettings != nil else {
            showingLoader = false
            return
        }
        await generateSongServiceSettingsRows()
        showingLoader = false
    }
    
    func isSelected(_ cluster: ClusterCodable) -> Bool {
        customSelectedSongs.contains(where: { $0.id == cluster.id }) || sectionedSongs.flatMap { $0.cocList }.compactMap { $0.cluster }.contains(where: { $0.id == cluster .id })
    }
    
    func didSelect(_ collection: ClusterCodable) {
        if let index = customSelectedSongs.firstIndex(where: { $0.id == collection.id }) {
            customSelectedSongs.remove(at: index)
        } else {
            customSelectedSongs.append(collection)
        }
    }
    
    func delete(_ collection: ClusterCodable) {
        if let index = customSelectedSongs.firstIndex(where: { $0.id == collection.id }) {
            customSelectedSongs.remove(at: index)
        }
    }
    
    func add(_ collection: ClusterCodable, to section: SongServiceSectionWithSongs) {
        guard let songServiceSettings, let index = sectionedSongs.firstIndex(where: { $0.id == section.id }) else { return }
        
        sectionedSongs.remove(at: index)
        
        var clusterComments: [ClusterComment] = [.cluster(collection)] + section.cocList.compactMap({ $0.cluster }).map({ .cluster($0) })
        if clusterComments.count < songServiceSettings.sections[index].numberOfSongs.intValue {
            clusterComments.append(.comment)
        }
        
        sectionedSongs.append(SongServiceSectionWithSongs(title: section.title, cocList: clusterComments))
    }
    
    func getShareInfo() async -> (title: String, content: String)? {
        return await SongServiceGeneratorUseCase().generateShareTextOnlyTitles(customSelectedSongs)
    }
    
    func getShareInfoTitlesOnly() async -> (title: String, content: String)? {
        return await SongServiceGeneratorUseCase().generateShareTextTitleAndContent(sectionedSongs)
    }
    
    private func generateSongServiceSettingsRows() async {
        if let songServiceSettings {
            self.sectionedSongs = await SongServiceGeneratorUseCase().generate(for: songServiceSettings)
        }
    }
}

struct SongServiceEditorViewUI: View {
    
    @ObservedObject var songService: SongServiceUI
    @ObservedObject var viewModel: SongServiceEditorModel
    @State private var showingCollectionsView = false
    @State private var editingSection: SongServiceSectionWithSongs? = nil
    @Binding var showingSongServiceEditorViewUI: Bool

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showingLoader {
                    ProgressView()
                }
                if viewModel.sectionedSongs.count > 0 {
                    songServiceView
                } else {
                    customSelectionView
                }
            }
            .navigationTitle(AppText.NewSongService.title)
            .toolbar {
                if !viewModel.showingLoader {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        doneButton
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        ForEach(viewModel.editButtons) { buttonType in
                            switch buttonType {
                            case .add: addButton
                            case .generateSongService: generateSongServiceButton
                            case .share: shareButon
                            case .delete: deleteButton
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingCollectionsView, content: {
            CollectionsViewUI(editingSection: nil, songServiceEditorModel: viewModel, showingCollectionsViewUI: $showingCollectionsView)
        })
        .sheet(item: $editingSection) { editingSection in
            if let sectionIndex = viewModel.sectionedSongs.firstIndex(where: { $0.id == editingSection.id }) {
                let mandatoryTags = viewModel.songServiceSettings?.sections[sectionIndex].tags ?? []
                CollectionsViewUI(
                    editingSection: editingSection,
                    songServiceEditorModel: viewModel,
                    mandatoryTags: mandatoryTags,
                    tagSelectionModel: TagSelectionModel(mandatoryTags: mandatoryTags)
                )
            }
        }
    }
    
    @ViewBuilder var songServiceView: some View {
        Form {
            ForEach(viewModel.sectionedSongs) { section in
                Section(section.title) {
                    List {
                        ForEach(section.cocList) { coc in
                            Button {
                                editingSection = section
                            } label: {
                                HStack {
                                    switch coc {
                                    case .cluster(let cluster):
                                        Text(cluster.title ?? "")
                                            .styleAs(font: .xNormal)
                                            .multilineTextAlignment(.leading)
                                        
                                    case .comment:
                                        Text(AppText.NewSongService.noSelectedSongs)
                                            .styleAs(font: .xNormal)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                }
                            }
                            .buttonStyle(.borderless)
                            .tint(.black.opacity(0.8))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder var customSelectionView: some View {
        List {
            ForEach(viewModel.customSelectedSongs) { song in
                Text(song.title ?? "")
                    .styleAs(font: .xNormal)
                    .swipeActions {
                        Button {
                            viewModel.delete(song)
                        } label: {
                            Image(systemName: "trash")
                                .tint(.white)
                        }
                        .tint(Color(uiColor: .red1))
                    }
            }
        }
    }
    
    @ViewBuilder var addButton: some View {
        Button {
            showingCollectionsView.toggle()
        } label: {
            Label {
                Text(AppText.Actions.add)
            } icon: {
                Image(systemName: "plus")
            }
        }
        .tint(Color(uiColor: themeMainColor))
    }
    
    @ViewBuilder var generateSongServiceButton: some View {
        Button {
            Task {
                await viewModel.fetchSongServiceSettingsRemotely()
            }
        } label: {
            Label {
                Text(AppText.Actions.generateSongService)
            } icon: {
                Image("MagicWand")
            }
        }
        .tint(Color(uiColor: themeMainColor))
    }

    @ViewBuilder var shareButon: some View {
        Menu {
            Button {
                Task {
                    guard let shareInfo = await viewModel.getShareInfoTitlesOnly() else { return }
                    EmailController.shared.sendEmail(subject: shareInfo.title, body: shareInfo.content)
                }
            } label: {
                Text(AppText.NewSongService.shareOptionTitles)
            }
            Button {
                Task {
                    guard let shareInfo = await viewModel.getShareInfo() else { return }
                    await MainActor.run(body: {
                        EmailController.shared.sendEmail(subject: shareInfo.title, body: shareInfo.content)
                    })
                }
            } label: {
                Text(AppText.NewSongService.shareOptionTitlesWithSections)
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .tint(Color(uiColor: themeMainColor))
    }

    @ViewBuilder var deleteButton: some View {
        Button {
            viewModel.reset()
        } label: {
            Image(systemName: "trash")
        }
        .tint(Color(uiColor: themeMainColor))
    }
    
    @ViewBuilder var doneButton: some View {
        Button {
            if viewModel.customSelectedSongs.count > 0 {
                songService.set(sectionedSongs: [SongServiceSectionWithSongs(title: "", cocList: viewModel.customSelectedSongs.map { .cluster($0) })])
            } else {
                songService.set(sectionedSongs: viewModel.sectionedSongs)
            }
            showingSongServiceEditorViewUI.toggle()
        } label: {
            Text(AppText.Actions.done)
        }
        .tint(Color(uiColor: themeMainColor))
    }

}

struct SongServiceEditorViewUI_Previews: PreviewProvider {
    @State static var model = SongServiceUI()
    @State static var showing = false
    static var previews: some View {
        SongServiceEditorViewUI(songService: model, viewModel: SongServiceEditorModel(), showingSongServiceEditorViewUI: $showing)
    }
}
