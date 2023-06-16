//
//  LyricsOrBibleStudyInputViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

protocol LyricsOrBibleStudyInputViewModelDelegate {
    func didSave(content: String)
}

@MainActor class LyricsOrBibleStudyInputViewModel: ObservableObject {
    
    let originalContent: String

    @State var font: UIFont.TextStyle = .body
    @Published var showingNumberOfSheetsError = false
    @Binding var content: String
    @State var error: LocalizedError?

    private let lyricsUseCase = GenerateLyricsSheetContentUseCase()
    private let delegate: LyricsOrBibleStudyInputViewModelDelegate?
    private let isNewSong: Bool
    @State private var cluster: ClusterCodable
    @State private var collectionType: CollectionEditorViewModel.CollectionType
    @Binding private var sheetPresentMode: CollectionEditorViewUI.SheetPresentMode?
    
    var textViewPlaceholder: String {
        collectionType == .lyrics ? AppText.Lyrics.placeholderLyrics : AppText.Lyrics.placeholderBibleText
    }
    
    init(
        originalContent: String,
        content: Binding<String>,
        cluster: ClusterCodable,
        font: UIFont.TextStyle,
        collectionType: CollectionEditorViewModel.CollectionType,
        delegate: LyricsOrBibleStudyInputViewModelDelegate?,
        sheetPresentMode: Binding<CollectionEditorViewUI.SheetPresentMode?>,
        isNewSong: Bool
    ) {
        self.originalContent = originalContent
        self.delegate = delegate
        self._content = content
        self.cluster = cluster
        self._sheetPresentMode = sheetPresentMode
        self.isNewSong = isNewSong
        self._collectionType = State(initialValue: collectionType)
    }
    
    func close() {
        sheetPresentMode = nil
    }
    
    func save(changedContent: String) async {
        do {
            if collectionType == .lyrics {
                let numberOfSheetsOriginal = try await lyricsUseCase.buildSheetsModels(from: originalContent, cluster: cluster).count
                let numberOfSheetsNew = try await lyricsUseCase.buildSheetsModels(from: changedContent, cluster: cluster).count
                if !isNewSong, numberOfSheetsOriginal != 0 && (numberOfSheetsNew != numberOfSheetsOriginal) {
                    showingNumberOfSheetsError.toggle()
                } else {
                    delegate?.didSave(content: changedContent)
                    sheetPresentMode = nil
                }
            } else {
                delegate?.didSave(content: changedContent)
                sheetPresentMode = nil
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
}

struct LyricsOrBibleStudyInputViewUI: View {
    
    @ObservedObject var viewModel: LyricsOrBibleStudyInputViewModel
    @State private var changedContent: String = ""
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                TextView(text: $changedContent, textStyle: $viewModel.font, placeholder: viewModel.textViewPlaceholder)
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle(AppText.NewSong.title)
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            closeButton
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            deleteContentButton
                            saveButton
                        }
                    })
                    .alert(Text(AppText.CustomSheets.universalSongEditErrorMessage), isPresented: $viewModel.showingNumberOfSheetsError) {
                        Button(AppText.Actions.ok, role: .cancel) {
                        }
                    }
                    .errorAlert(error: $viewModel.error)
                    .onAppear {
                        changedContent = viewModel.originalContent
                    }
            }
        }
    }
    
    @ViewBuilder private var closeButton: some View {
        Button(AppText.Actions.close) {
            viewModel.close()
        }
        .tint(Color(uiColor: themeHighlighted))
    }
    
    @ViewBuilder private var saveButton: some View {
        Button(AppText.Actions.save) {
            Task {
                await viewModel.save(changedContent: changedContent)
            }
        }
        .tint(Color(uiColor: themeHighlighted))
    }
    
    @ViewBuilder var deleteContentButton: some View {
        Button(action: {
            changedContent = ""
        }, label: {
            Image(systemName: "trash")
        })
        .tint(Color(uiColor: themeHighlighted))
    }
}

struct LyricsOrBibleStudyInputViewUI_Previews: PreviewProvider {
    @State static var isShowingBibleStudy: CollectionEditorViewUI.SheetPresentMode? = nil
    @State static var content: String = ""
    static var previews: some View {
        LyricsOrBibleStudyInputViewUI(viewModel: LyricsOrBibleStudyInputViewModel(originalContent: "", content: $content, cluster: .makeDefault()!, font: .callout, collectionType: .lyrics, delegate: nil, sheetPresentMode: $isShowingBibleStudy, isNewSong: true))
    }
}
