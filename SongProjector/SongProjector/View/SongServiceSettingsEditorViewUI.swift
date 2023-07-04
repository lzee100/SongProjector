//
//  SongServiceSettingsEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import Combine


@MainActor class SongServiceSettingsEditorViewModel: ObservableObject {
    
    @Published fileprivate var sections: [SongServiceSettingsSection]
    private let songServiceSettings: SongServiceSettingsCodable
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var error: LocalizedError?
    @Published var showingTagSelectorView = false
    var selectedSectionForTagSelection: SongServiceSectionCodable?
    let pinnableTags = PassthroughSubject<[PinnableTagCodable], Never>()
    private var cancables: [AnyCancellable] = []
    
    init(songServiceSettings: SongServiceSettingsCodable) {
        self.songServiceSettings = songServiceSettings
        self.sections = songServiceSettings.sections.map { SongServiceSettingsSection(songServiceSection: $0) }
        pinnableTags.sink { [weak self] tags in
            guard let self, let selectedSectionForTagSelection = self.selectedSectionForTagSelection else { return }
            if let index = self.sections.firstIndex(where: { $0.songServiceSection?.id == selectedSectionForTagSelection.id }) {
                self.sections[index].pinnableTags = tags.map { WrappedStruct(withItem: $0) }
            }
        }.store(in: &cancables)
    }
    
    var evaluatedErrorMessage: String? {
        if sections.count == 0 {
            return AppText.SongServiceManagement.errorAddASection
        } else {
            var errorSectionIndexes: [Int] = []
            for (index, section) in sections.enumerated() {
                if !section.isValid {
                    errorSectionIndexes.append(index + 1)
                }
            }
            if errorSectionIndexes.count > 1 {
                return AppText.SongServiceManagement.errorInSections(errorSectionIndexes)
            } else if let errorIndex = errorSectionIndexes.first {
                return AppText.SongServiceManagement.errorInSection(errorIndex)
            }
            return nil
        }
    }
    
    func appendSection() {
        sections.append(SongServiceSettingsSection())
    }
    
    func saveSettings() async {
        if let evaluatedErrorMessage {
            self.errorMessage = evaluatedErrorMessage
        } else {
            isLoading = true
            do {
                try await SubmitUseCase<SongServiceSettingsCodable>(endpoint: .songservicesettings, requestMethod: .put, uploadObjects: [updateSongServiceSettings()]).submit()
                isLoading = false
            } catch {
                isLoading = false
                self.error = error.forcedLocalizedError
            }
        }
    }
    
    func getPinnableTagsForSelectedSection() -> [PinnableTagCodable] {
        guard let selectedSectionForTagSelection, let index = sections.firstIndex(where: { $0.songServiceSection?.id == selectedSectionForTagSelection.id }) else { return [] }
        let selectedItems = sections[index].pinnableTags.map { $0.item }
        return selectedItems.count == 0 ? sections[index].songServiceSection?.tags.map { PinnableTagCodable(tag: $0) } ?? [] : selectedItems
    }
    
    private func updateSongServiceSettings() -> SongServiceSettingsCodable {
        var newSections: [SongServiceSectionCodable] = []
        for (index, section) in sections.enumerated() {
            newSections.append(SongServiceSectionCodable(title: section.title, position: index, numberOfSongs: section.numberOfSongs, tags: [],  pinnableTags: section.pinnableTags.map { $0.item } ))
        }
        var changeableSettings = songServiceSettings
        changeableSettings.sections = newSections
        return changeableSettings
    }
    
}

struct SongServiceSettingsEditorViewUI: View {
    
    @Binding var showingSongServiceSettings: SongServiceSettingsCodable?
    @StateObject var viewModel: SongServiceSettingsEditorViewModel
    @State private var tagSelectionViewModel = WrappedStruct(withItem: TagSelectionModel(mandatoryTags: []))
    @State private var showingErrorMessage = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Form {
                    ForEach(Array(zip(viewModel.sections.indices, viewModel.sections)), id: \.0) { index, _ in
                        sectionViewFor(index)
                    }
                }
                .blur(radius: viewModel.isLoading ? 5 : 0)
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        viewModel.appendSection()
                    } label: {
                        HStack(spacing: 10) {
                            Text(AppText.SongServiceManagement.addSection)
                            Image(systemName: "plus")
                        }
                        .tint(Color(uiColor: themeHighlighted))
                    }
                    Spacer()
                }
            }
            .alert(Text(viewModel.errorMessage ?? ""), isPresented: $showingErrorMessage, actions: {
                Button(AppText.Actions.ok, role: .cancel) {
                    viewModel.errorMessage = nil
                }
            })
            .errorAlert(error: $viewModel.error)
            .navigationTitle(AppText.SongServiceManagement.titleNewSongServiceSchema)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showingSongServiceSettings = nil
                    } label: {
                        Text(AppText.Actions.close)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.saveSettings()
                        }
                    } label: {
                        Text(AppText.Actions.save)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                    .allowsHitTesting(!viewModel.isLoading)
                }
            }
            .sheet(isPresented: $viewModel.showingTagSelectorView, content: {
                TagSelectionListForSectionViewUI(
                    songServiceSectionCodable: viewModel.selectedSectionForTagSelection!,
                    pinnableTags: viewModel.getPinnableTagsForSelectedSection(),
                    showingTagSelectionListForSectionViewUI: $viewModel.showingTagSelectorView,
                    pinnableTagsPassThrough: viewModel.pinnableTags
                )
                .presentationDetents([.medium, .large])
            })
            .onChange(of: viewModel.isLoading) { isLoading in
                if !isLoading {
                    showingSongServiceSettings = nil
                }
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                showingErrorMessage = newValue != nil
            }
        }
    }
    
    @ViewBuilder private func sectionViewFor(_ index: Int) -> some  View {
        Section {
            
            HStack {
                TextField(AppText.SongServiceManagement.nameSection, text: $viewModel.sections[index].title)
                    .styleAs(font: .xxNormal)
                    .textFieldStyle(.roundedBorder)
                    .frame(idealWidth: 400, maxWidth: 400)
                Spacer()
                Button {
                    viewModel.sections.remove(at: index)
                } label: {
                    Image(systemName: "trash")
                        .tint(Color(uiColor: themeHighlighted))
                        .padding([.leading], 50)
                }
                .buttonStyle(.borderless)
            }
            .padding([.top], 20)
            .listRowSeparator(.hidden)

            NumberModifierViewUI(
                viewModel: NumberModifierViewModel<Int>.init(label: AppText.SongServiceManagement.numberOfSongs, allowSubstraction: { value in
                    value > 1
                }, allowIncrement: { value in
                    value <= 30
                }, numberValue: $viewModel.sections[index].numberOfSongs)
            )
            .frame(height: 30)
            .padding([.bottom], 5)

            Group {
                VStack(alignment: .leading) {
                    Text("Tags")
                        .styleAs(font: .xxNormalBold)
                    ForEach(Array(zip(viewModel.sections[index].pinnableTags.indices, viewModel.sections[safe: index]!.pinnableTags)), id: \.0) { tagIndex, tag in
                        Toggle(isOn: $viewModel.sections[safe: index]!.pinnableTags[tagIndex].item.isPinned) {
                            HStack {
                                Button(action: {
                                    
                                }, label: {
                                    Text(tag.item.title ?? "")
                                })
                                .styleAsSelectionCapsuleButton(isSelected: false)
                                .disabled(true)
                                Spacer()
                                Button {
                                    print("pressed question mark")
                                } label: {
                                    HStack(alignment: .top) {
                                        Text("Mandatory")
                                            .styleAs(font: .small)
                                        Image(systemName: "questionmark")
                                            .frame(width: 5, height: 5)
                                            .foregroundColor(Color(uiColor: themeHighlighted))
                                            .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        viewModel.selectedSectionForTagSelection = viewModel.sections[index].songServiceSection
                        viewModel.showingTagSelectorView = true
                    } label: {
                        Text(AppText.SongServiceManagement.addTags)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
            }
            .padding([.bottom], 20)

        }
    }

}

struct SongServiceSettingsEditorViewUI_Previews: PreviewProvider {
    @State static var settings: SongServiceSettingsCodable? = nil
    @State static var viewModel = SongServiceSettingsEditorViewModel(songServiceSettings: .makeDefault()!)
    static var previews: some View {
        SongServiceSettingsEditorViewUI(showingSongServiceSettings: $settings, viewModel: viewModel)
    }
}
