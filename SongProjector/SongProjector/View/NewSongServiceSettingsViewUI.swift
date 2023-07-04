//
//  NewSongServiceSettingsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import FirebaseAuth

class SongServiceSettingsSection {
    
    public let id = UUID().uuidString
    let songServiceSection: SongServiceSectionCodable?
    @Published var title = ""
    @Published var numberOfSongs: Int = 1
    @Published var pinnableTags: [WrappedStruct<PinnableTagCodable>] = []
    
    var isValid: Bool {
        return !title.isBlanc && pinnableTags.count > 0 && numberOfSongs > 0
    }
    
    init(songServiceSection: SongServiceSectionCodable? = nil) {
        self.songServiceSection = songServiceSection
        title = songServiceSection?.title ?? ""
        if songServiceSection?.pinnableTags.count ?? 0 > 0 {
            pinnableTags = songServiceSection?.pinnableTags.map { WrappedStruct(withItem: $0)} ?? []
        } else {
            pinnableTags = songServiceSection?.tags.map { WrappedStruct(withItem: PinnableTagCodable(tag: $0)) } ?? []
        }
        numberOfSongs = songServiceSection?.numberOfSongs.intValue ?? 1
    }
    
}

@MainActor class NewSongServiceSettingsViewModel: ObservableObject {
    
    @Published fileprivate var sections: [SongServiceSettingsSection] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var error: LocalizedError?
    
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
                
                try await SubmitUseCase<SongServiceSettingsCodable>(endpoint: .songservicesettings, requestMethod: .put, uploadObjects: [createSongServiceSettings()]).submit()
                isLoading = false
            } catch {
                isLoading = false
                self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
            }
        }
    }
    
    private func createSongServiceSettings() -> SongServiceSettingsCodable {
        var newSections: [SongServiceSectionCodable] = []
        for (index, section) in sections.enumerated() {
            newSections.append(SongServiceSectionCodable(position: index, numberOfSongs: section.numberOfSongs, tags: [], pinnableTags: section.pinnableTags.map { $0.item }))
        }
        var changeableSettings = SongServiceSettingsCodable.makeDefault(userUID: (Auth.auth().currentUser?.uid)!)!
        
        changeableSettings.sections = newSections
        return changeableSettings
    }

}

struct NewSongServiceSettingsViewUI: View {
    
    @Binding var showingNewSongServiceSettingsView: Bool
    @StateObject private var viewModel = NewSongServiceSettingsViewModel()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Form {
                    ForEach(Array(zip(viewModel.sections.indices, viewModel.sections)), id: \.0) { index, _ in
                        sectionViewFor(index)
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
                        .padding()
                    }
                    Spacer()
                }
            }
            .blur(radius: viewModel.isLoading ? 5 : 0)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle(AppText.SongServiceManagement.titleNewSongServiceSchema)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showingNewSongServiceSettingsView.toggle()
                    } label: {
                        Text(AppText.Actions.cancel)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.saveSettings()
                            showingNewSongServiceSettingsView.toggle()
                        }
                    } label: {
                        Text(AppText.Actions.save)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
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
            .listRowSeparator(.hidden)
            .padding([.top], 20)

            NumberModifierViewUI(
                viewModel: NumberModifierViewModel<Int>.init(label: AppText.SongServiceManagement.numberOfSongs, allowSubstraction: { value in
                    value > 1
                }, allowIncrement: { value in
                    value <= 30
                }, numberValue: $viewModel.sections[index].numberOfSongs)
            )
            .frame(height: 35)
            .padding([.bottom], 3)
            
            Group {
                Button {
                    
                } label: {
                    Text(AppText.SongServiceManagement.addTags)
                        .tint(Color(uiColor: themeHighlighted))
                }
                
            }
            .padding([.bottom], 20)
            
        }
    }

}

struct NewSongServiceSettingsViewUI_Previews: PreviewProvider {
    @State static var isShowing = false
    static var previews: some View {
        NewSongServiceSettingsViewUI(showingNewSongServiceSettingsView: $isShowing)
    }
}
