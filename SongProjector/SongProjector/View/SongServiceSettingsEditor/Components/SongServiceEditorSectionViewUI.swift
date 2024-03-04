//
//  SongServiceEditorSectionViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/07/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class SongServiceEditorSectionViewModel: ObservableObject, Identifiable {
    
    enum Output {
        case isValid(section: Int, isValid: Bool)
        case didTapTagSelection(section: Int)
        case delete(section: Int)
    }
    
    public let id = UUID().uuidString
    
    let songServiceSection: SongServiceSectionCodable
    @Published var title = ""
    @Published var numberOfSongs: Int = 1
    @Published var tags: [TagInSchemeCodable] = []
    private let output = PassthroughSubject<Output, Never>()
    private var cancables: [AnyCancellable] = []
    private var section: Int {
        songServiceSection.position.intValue
    }    
    var isValid: Bool {
        return !title.isBlanc && tags.count > 0 && numberOfSongs > 0
    }

    init(
        songServiceSection: SongServiceSectionCodable
    ) {
        self.songServiceSection = songServiceSection
        
        title = songServiceSection.title ?? ""
        tags = songServiceSection.tags
        numberOfSongs = songServiceSection.numberOfSongs.intValue
    }
    
    func bind() -> AnyPublisher<Output, Never> {
        return output.eraseToAnyPublisher()
    }
    
    func deleteSection() {
        output.send(.delete(section: section))
    }
    
    func textFieldDidChange() {
        output.send(.isValid(section: section, isValid: isValid))
    }
    
    func showTagSelectionView() {
        output.send(.didTapTagSelection(section: section))
    }
    
    func didSelect(_ tags: [TagCodable]) {
        let oldTags = self.tags
        func isPinned(_ tag: TagCodable) -> Bool {
            return oldTags.first(where: { $0.rootTagId == tag.id })?.isPinned ?? false
        }
        self.tags = tags.map({ tag in
            return TagInSchemeCodable(title: tag.title, createdAt: Date(), updatedAt: Date(), rootTagId: tag.id, isPinned: isPinned(tag))
        })
        output.send(.isValid(section: section, isValid: isValid))
    }
}

struct SongServiceEditorSectionViewUI: View {
    
    @StateObject var viewModel: SongServiceEditorSectionViewModel
    
    var body: some View {
        Section {
            titleTextFieldViewAndDeleteButton
            numberOfSongsInputView
            tagHeaderAndTagsListView
            addTagButtonView
        }
    }
    
    @ViewBuilder private var titleTextFieldViewAndDeleteButton: some View {
        HStack {
            TextField(AppText.SongServiceManagement.nameSection, text: $viewModel.title)
                .styleAs(font: .xxNormal)
                .textFieldStyle(.roundedBorder)
                .frame(idealWidth: 400, maxWidth: 400)
                .onChange(of: viewModel.title) { newValue in
                    viewModel.textFieldDidChange()
                }
            Spacer()
            Button {
                viewModel.deleteSection()
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
            }, numberValue: $viewModel.numberOfSongs)
        )
        .frame(height: 30)
        .padding([.bottom], 5)
    }
    
    @ViewBuilder private var tagHeaderAndTagsListView: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .styleAs(font: .xxNormalBold)
            ForEach(Array(zip(viewModel.tags.indices, viewModel.tags)), id: \.0) { tagIndex, tag in
                HStack {
                    Button(action: {
                        
                    }, label: {
                        Text(tag.title ?? "")
                    })
                    .styleAsSelectionCapsuleButton(isSelected: false)
                    .disabled(true)
                    Spacer()
                    
                    Button {
                        viewModel.tags[tagIndex].isPinned.toggle()
                    } label: {
                        Image(systemName: viewModel.tags[tagIndex].isPinned ? "pin.fill" : "pin")
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
                viewModel.showTagSelectionView()
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
