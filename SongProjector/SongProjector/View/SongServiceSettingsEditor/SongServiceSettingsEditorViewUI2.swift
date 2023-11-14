//
//  SongServiceSettingsEditorViewUI2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct SongServiceSettingsEditorViewUI2: View {

    private enum SongServiceSettingsError: LocalizedError {
        case noTagIn(section: SongServiceSectionCodable)
        case noTitleIn(section: SongServiceSectionCodable)
        case wrongNumberOfSongsFor(section: SongServiceSectionCodable)

        var errorDescription: String? {
            switch self {
            case .noTagIn(section: let section): return AppText.SongServiceManagement.tagError(sectionIndex: section.position.intValue, sectionName: section.title ?? "")
            case .noTitleIn(section: let section): return AppText.SongServiceManagement.titleError(sectionIndex: section.position.intValue)
            case .wrongNumberOfSongsFor(section: let section): return AppText.SongServiceManagement.numberOfSongsError(sectionIndex: section.position.intValue, sectionName: section.title ?? "")
            }
        }
    }

    @StateObject var songServiceSettings: WrappedStruct<SongServiceSettingsCodable>

    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var selectedSection: SongServiceSectionCodable?
    @State private var isLoading = false
    @State private var error: LocalizedError?

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    ForEach(songServiceSettings.item.sections) { section in
                        SongServiceEditorSectionViewUI2(section: section) {
                            didDeleteSection(section)
                        } titleDidChange: { title in
                            titleDidChange(section, title: title)
                        } numberOfSongsDidChange: { numberOfSongs in
                            numberOfSongsDidChange(section, numberOfSongs: numberOfSongs)
                        } didPinTag: { tag in
                            didPinTag(section, tag: tag)
                        } didSelectAddTags: {
                            selectedSection = section
                        }
                    }
                }
                .blur(radius: isLoading ? 5 : 0)
                .overlay {
                    if isLoading {
                        ProgressView()
                    }
                }
                HStack {
                    Spacer()
                    addSectionButton
                    Spacer()
                }
            }
            .errorAlert(error: $error)
            .navigationTitle(AppText.SongServiceManagement.titleNewSongServiceSchema)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    closeButton
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .sheet(item: $selectedSection, content: { section in
                TagSelectionListForSectionViewUI2(isSelected: isTagSelected, didSelect: didSelect, didSelectDone: {
                    selectedSection = nil
                })
                .presentationDetents([.medium, .large])
            })
        }
    }

    @ViewBuilder private var saveButton: some View {
        Button {
            checkSongServiceSettings()
            if error == nil {
                Task {
                    await saveSettings()
                }
            }
        } label: {
            Text(AppText.Actions.save)
                .tint(Color(uiColor: themeHighlighted))
        }
        .allowsHitTesting(!isLoading)
    }

    @ViewBuilder private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text(AppText.Actions.close)
                .tint(Color(uiColor: themeHighlighted))
        }
    }

    @ViewBuilder private var addSectionButton: some View {
        Button {
            addNewSection()
        } label: {
            HStack(spacing: 10) {
                Text(AppText.SongServiceManagement.addSection)
                Image(systemName: "plus")
            }
            .tint(Color(uiColor: themeHighlighted))
        }
    }

    private func didSelect(_ tag: TagCodable) {
        if let index = songServiceSettings.item.sections.firstIndex(where: { $0.id == selectedSection?.id }), songServiceSettings.item.sections[index].tags.contains(where: { $0.rootTagId == tag.id }) {
            songServiceSettings.item.sections[index].tags.removeAll(where: { $0.rootTagId == tag.id })
        } else if let index = songServiceSettings.item.sections.firstIndex(where: { $0.id == selectedSection?.id }) {
            let newTag = TagInSchemeCodable(title: tag.title, createdAt: Date(), rootTagId: tag.id, isPinned: false, positionInScheme: songServiceSettings.item.sections[index].tags.count)
            songServiceSettings.item.sections[index].tags.append(newTag)
        }
    }

    private func isTagSelected(_ tag: TagCodable) -> Bool {
        if let index = songServiceSettings.item.sections.firstIndex(where: { $0.id == selectedSection?.id }) {
            return songServiceSettings.item.sections[index].tags.contains(where: { $0.rootTagId == tag.id})
        }
        return false
    }

    private func addNewSection() {
        if let section = SongServiceSectionCodable.makeDefault(title: "", position: songServiceSettings.item.sections.count, numberOfSongs: 1, tags: []) {
            songServiceSettings.item.sections.append(section)
        }
    }

    private func saveSettings() async {
        isLoading = true
        do {
            try await SubmitUseCase<SongServiceSettingsCodable>(endpoint: .songservicesettings, requestMethod: .put, uploadObjects: [updateSongServiceSettings()]).submit()
            isLoading = false
            dismiss()
        } catch {
            isLoading = false
            self.error = error.forcedLocalizedError
        }
    }

    private func updateSongServiceSettings() -> SongServiceSettingsCodable {
        var newSections: [SongServiceSectionCodable] = []
        for (index, section) in songServiceSettings.item.sections.enumerated() {
            var tags: [TagInSchemeCodable] {
                var tags: [TagInSchemeCodable] = []
                for (index, tag) in section.tags.enumerated() {
                    var tag = tag
                    tag.positionInScheme = index
                    tags.append(tag)
                }
                return tags
            }

            newSections.append(SongServiceSectionCodable(
                title: section.title,
                position: index,
                numberOfSongs: section.numberOfSongs.intValue,
                tags: tags
            ))
        }
        var changeableSettings = songServiceSettings.item
        changeableSettings.sections = newSections
        return changeableSettings
    }

    private func checkSongServiceSettings() {
        if let section = songServiceSettings.item.sections.first(where: { $0.title?.isEmpty ?? true }) {
            error = SongServiceSettingsError.noTitleIn(section: section)
        } else if let section = songServiceSettings.item.sections.first(where: { $0.tags.count == 0 }) {
            error = SongServiceSettingsError.noTagIn(section: section)
        } else if let section = songServiceSettings.item.sections.first(where: { $0.numberOfSongs < 1 }) {
            error = SongServiceSettingsError.wrongNumberOfSongsFor(section: section)
        } else {
            error = nil
        }
    }

    private func didDeleteSection(_ section: SongServiceSectionCodable) {
        if let index = songServiceSettings.item.sections.firstIndex(where: { $0.id == section.id }) {
            songServiceSettings.item.sections.remove(at: index)
        }
    }

    private func titleDidChange(_ section: SongServiceSectionCodable, title: String) {
        if let index = songServiceSettings.item.sections.firstIndex(where: { $0.id == section.id }) {
            songServiceSettings.item.sections[index].title = title
        }
    }

    private func numberOfSongsDidChange(_ section: SongServiceSectionCodable, numberOfSongs: Int) {
        if let index = songServiceSettings.item.sections.firstIndex(where: { $0.id == section.id }) {
            songServiceSettings.item.sections[index].numberOfSongs = Int16(numberOfSongs)
        }
    }

    private func didPinTag(_ section: SongServiceSectionCodable, tag: TagInSchemeCodable) {
        if let index = songServiceSettings.item.sections.firstIndex(where: { $0.id == section.id }), let tagIndex = songServiceSettings.item.sections[index].tags.firstIndex(where: { $0.id == tag.id }) {
            songServiceSettings.item.sections[index].tags[tagIndex].isPinned.toggle()
        }
    }
}

#Preview {
    SongServiceSettingsEditorViewUI2(songServiceSettings: WrappedStruct(withItem: SongServiceSettingsCodable.makeDefault()!))
}

struct SongServiceEditorSectionViewUI2: View {

    let section: SongServiceSectionCodable
    let didDeleteSection: (() -> Void)
    let titleDidChange: ((String) -> Void)
    let numberOfSongsDidChange: ((Int) -> Void)
    let didPinTag: ((TagInSchemeCodable) -> Void)
    let didSelectAddTags: (() -> Void)

    @State private var sectionTitle = ""
    @State private var numberOfSongsInSection = 1

    var body: some View {
        Section {
            titleTextFieldViewAndDeleteButton
            numberOfSongsInputView
            tagHeaderAndTagsListView
            addTagButtonView
        }
        .onAppear {
            sectionTitle = section.title ?? ""
            numberOfSongsInSection = section.numberOfSongs.intValue
        }
    }

    @ViewBuilder private var titleTextFieldViewAndDeleteButton: some View {
        HStack {
            TextField(AppText.SongServiceManagement.nameSection, text: $sectionTitle)
                .styleAs(font: .xxNormal)
                .textFieldStyle(.roundedBorder)
                .frame(idealWidth: 400, maxWidth: 400)
                .onChange(of: sectionTitle) { _, newValue in
                    titleDidChange(newValue)
                }
            Spacer()
            Button {
                didDeleteSection()
            } label: {
                Image(systemName: "trash")
                    .tint(Color(uiColor: themeHighlighted))
                    .padding([.leading], 50)
            }
            .buttonStyle(.borderless)
        }
        .padding([.top], 20)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder private var numberOfSongsInputView: some View {
        NumberModifierViewUI(
            viewModel: NumberModifierViewModel<Int>.init(label: AppText.SongServiceManagement.numberOfSongs, allowSubstraction: { value in
                value > 1
            }, allowIncrement: { value in
                value <= 30
            }, numberValue: $numberOfSongsInSection)
        )
        .frame(height: 30)
        .padding([.bottom], 5)
        .onChange(of: numberOfSongsInSection) { _, newValue in
            numberOfSongsDidChange(newValue)
        }
    }

    @ViewBuilder private var tagHeaderAndTagsListView: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .styleAs(font: .xxNormalBold)
            ForEach(Array(zip(section.tags.indices, section.tags)), id: \.0) { tagIndex, tag in
                HStack {
                    Button(action: {}, label: {
                        Text(tag.title ?? "")
                    })
                    .styleAsSelectionCapsuleButton(isSelected: false)
                    .disabled(true)
                    Spacer()

                    Button {
                        didPinTag(tag)
                    } label: {
                        Image(systemName: section.tags[tagIndex].isPinned ? "pin.fill" : "pin")
                            .frame(width: 5, height: 5)
                            .foregroundColor(Color(uiColor: themeHighlighted))
                            .padding()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private var addTagButtonView: some View {
        HStack {
            Spacer()
            Button {
                didSelectAddTags()
            } label: {
                Text(AppText.SongServiceManagement.addTags)
                    .tint(Color(uiColor: themeHighlighted))
            }
            .buttonStyle(.borderless)
            Spacer()
        }
        .padding([.bottom], 20)
    }
}

struct TagSelectionListForSectionViewUI2: View {

    let isSelected: ((TagCodable) -> Bool)
    let didSelect: ((TagCodable) -> Void)
    let didSelectDone: (() -> Void)

    @State private var error: LocalizedError?
    @State private var isLoading: Bool = false
    @State private var tags: [TagCodable] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(zip(tags.indices, tags)), id: \.0) { _, tag in
                    Button {
                        didSelect(tag)
                    } label: {
                        HStack(spacing: 8) {
                            Capsule().fill(isSelected(tag) ? Color(uiColor: .softBlueGrey) : .clear)
                                .frame(minWidth: 5, idealWidth: 5, maxWidth: 5, minHeight: 0, maxHeight: .infinity)
                            Text(tag.title ?? "")
                                .styleAs(font: .normal)
                        }
                    }
                }
            }
            .errorAlert(error: $error)
            .navigationTitle("Tags-SelectTags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        didSelectDone()
                    } label: {
                        Text(AppText.Actions.done)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
            }
            .task {
                await fetchRemoteTags()
            }
        }
    }

    private func fetchRemoteTags() async {
        tags = await GetTagsUseCase().fetch().sorted(by: { $0.position < $1.position })

        guard !isLoading else {
            return
        }
        isLoading = true
        do {
            _ = try await FetchTagsUseCase().fetch()
            isLoading = false
            tags = await GetTagsUseCase().fetch().sorted(by: { $0.position < $1.position })
        } catch {
            self.error = error.forcedLocalizedError
        }
    }
}
