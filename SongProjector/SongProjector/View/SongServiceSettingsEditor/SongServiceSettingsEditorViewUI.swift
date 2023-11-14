//
//  SongServiceSettingsEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import Combine


//@MainActor class SongServiceSettingsEditorViewModel: ObservableObject {
//    
//    @Published fileprivate var sections: [SongServiceEditorSectionViewModel] = []
//    private let songServiceSettings: SongServiceSettingsCodable
//    @Published var canSave = false
//    @Published private(set) var isLoading = false
//    @Published var errorMessage: String?
//    @Published var error: LocalizedError?
//    @Published var showingTagSelectorView = false
//    @Published var showingPinnedInformation = false
//    var selectedSectionViewModel: SongServiceEditorSectionViewModel?
//    let tags = PassthroughSubject<[TagCodable], Never>()
//    private var cancables: [AnyCancellable] = []
//    
//    init(songServiceSettings: SongServiceSettingsCodable = SongServiceSettingsCodable.makeDefault()!) {
//        self.songServiceSettings = songServiceSettings
//        
//        defer {
//            self.sections = songServiceSettings.sections.map {
//                let section = SongServiceEditorSectionViewModel(
//                    songServiceSection: $0
//                )
//                section.bind().sink { [weak self] output in
//                    self?.handle(output)
//                }.store(in: &cancables)
//                return section
//            }
//            updateCanSave()
//        }
//    }
//    
//    var evaluatedErrorMessage: String? {
//        if sections.count == 0 {
//            return AppText.SongServiceManagement.errorAddASection
//        } else {
//            var errorSectionIndexes: [Int] = []
//            for (index, section) in sections.enumerated() {
//                if !section.isValid {
//                    errorSectionIndexes.append(index + 1)
//                }
//            }
//            if errorSectionIndexes.count > 1 {
//                return AppText.SongServiceManagement.errorInSections(errorSectionIndexes)
//            } else if let errorIndex = errorSectionIndexes.first {
//                return AppText.SongServiceManagement.errorInSection(errorIndex)
//            }
//            return nil
//        }
//    }
//    
//    func appendSection() {
//        let newSection = SongServiceEditorSectionViewModel(
//            songServiceSection: SongServiceSectionCodable.makeDefault(
//                title: "",
//                position: sections.count,
//                numberOfSongs: 1,
//                tags: []
//            )!
//        )
//        newSection.bind().sink { [weak self] output in
//            self?.handle(output)
//        }.store(in: &cancables)
//        sections.append(newSection)
//        handle(.isValid(section: sections.count, isValid: false))
//    }
//    
//    func saveSettings() async {
//        if let evaluatedErrorMessage {
//            self.errorMessage = evaluatedErrorMessage
//        } else {
//            isLoading = true
//            do {
//                try await SubmitUseCase<SongServiceSettingsCodable>(endpoint: .songservicesettings, requestMethod: .put, uploadObjects: [updateSongServiceSettings()]).submit()
//                isLoading = false
//            } catch {
//                isLoading = false
//                self.error = error.forcedLocalizedError
//            }
//        }
//    }
//    
//    func getPinnableTagsForSelectedSection() -> [TagInSchemeCodable] {
//        selectedSectionViewModel?.tags ?? []
//    }
//    
//    private func updateSongServiceSettings() -> SongServiceSettingsCodable {
//        var newSections: [SongServiceSectionCodable] = []
//        for (index, section) in sections.enumerated() {
//            var tags: [TagInSchemeCodable] {
//                var tags: [TagInSchemeCodable] = []
//                for (index, tag) in section.tags.enumerated() {
//                    var tag = tag
//                    tag.positionInScheme = index
//                    tags.append(tag)
//                }
//                return tags
//            }
//            
//            newSections.append(SongServiceSectionCodable(
//                title: section.title,
//                position: index,
//                numberOfSongs: section.numberOfSongs,
//                tags: tags
//            ))
//        }
//        var changeableSettings = songServiceSettings
//        changeableSettings.sections = newSections
//        return changeableSettings
//    }
//    
//    private func handle(_ sectionOutput: SongServiceEditorSectionViewModel.Output) {
//        switch sectionOutput {
//        case .isValid(let section, let isValid):
//            updateCanSave()
//        case .didTapTagSelection(let section):
//            selectedSectionViewModel = sections[section]
//            showingTagSelectorView = true
//        case .delete(let section):
//            sections.remove(at: section)
//        }
//    }
//    
//    private func updateCanSave() {
//        canSave = !sections.contains(where: { !$0.isValid })
//    }
//}
//
//struct SongServiceSettingsEditorViewUI: View {
//    
//    @Binding var showingSongServiceSettings: SongServiceSettingsCodable?
//    @StateObject var viewModel: SongServiceSettingsEditorViewModel
//    @State private var tagSelectionViewModel = WrappedStruct(withItem: TagSelectionModel(mandatoryTagIds: []))
//    @State private var showingErrorMessage = false
//    
//    var body: some View {
//        
//        NavigationStack {
//            VStack {
//                Form {
//                    ForEach(viewModel.sections) { sectionViewModel in
//                        SongServiceEditorSectionViewUI(viewModel: sectionViewModel)
//                    }
//                }
//                .blur(radius: viewModel.isLoading ? 5 : 0)
//                .overlay {
//                    if viewModel.isLoading {
//                        ProgressView()
//                    }
//                }
//                HStack {
//                    Spacer()
//                    Button {
//                        viewModel.appendSection()
//                    } label: {
//                        HStack(spacing: 10) {
//                            Text(AppText.SongServiceManagement.addSection)
//                            Image(systemName: "plus")
//                        }
//                        .tint(Color(uiColor: themeHighlighted))
//                    }
//                    Spacer()
//                }
//            }
//            .alert(Text(viewModel.errorMessage ?? ""), isPresented: $showingErrorMessage, actions: {
//                Button(AppText.Actions.ok, role: .cancel) {
//                    viewModel.errorMessage = nil
//                }
//            })
//            .errorAlert(error: $viewModel.error)
//            .navigationTitle(AppText.SongServiceManagement.titleNewSongServiceSchema)
//            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    Button {
//                        showingSongServiceSettings = nil
//                    } label: {
//                        Text(AppText.Actions.close)
//                            .tint(Color(uiColor: themeHighlighted))
//                    }
//                }
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    Button {
//                        Task {
//                            await viewModel.saveSettings()
//                        }
//                    } label: {
//                        Text(AppText.Actions.save)
//                            .tint(Color(uiColor: themeHighlighted))
//                    }
//                    .disabled(!viewModel.canSave)
//                    .allowsHitTesting(!viewModel.isLoading)
//                }
//            }
//            .sheet(isPresented: $viewModel.showingTagSelectorView, content: {
//                if let selectedSectionViewModel = viewModel.selectedSectionViewModel {
//                    TagSelectionListForSectionViewUI(
//                        songServiceSettingsEditorViewModel: viewModel,
//                        editorSectionViewModel: selectedSectionViewModel,
//                        showingTagSelectionListForSectionViewUI: $viewModel.showingTagSelectorView
//                    )
//                    .presentationDetents([.medium, .large])
//                }
//            })
//            .onChange(of: viewModel.isLoading) { isLoading in
//                if !isLoading {
//                    showingSongServiceSettings = nil
//                }
//            }
//            .onChange(of: viewModel.errorMessage) { newValue in
//                showingErrorMessage = newValue != nil
//            }
//        }
//    }
//}
//
//struct SongServiceSettingsEditorViewUI_Previews: PreviewProvider {
//    @State static var settings: SongServiceSettingsCodable? = nil
//    @State static var viewModel = SongServiceSettingsEditorViewModel(songServiceSettings: .makeDefault()!)
//    static var previews: some View {
//        SongServiceSettingsEditorViewUI(showingSongServiceSettings: $settings, viewModel: viewModel)
//    }
//}
