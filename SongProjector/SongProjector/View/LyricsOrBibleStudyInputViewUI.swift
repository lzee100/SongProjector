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
    @State private var cluster: ClusterCodable
    @State private var collectionType: CollectionEditorViewModel.CollectionType
    @Binding private var sheetPresentMode: CollectionEditorViewUI.SheetPresentMode?
    
    init(
        originalContent: String,
        content: Binding<String>,
        cluster: ClusterCodable,
        font: UIFont.TextStyle,
        collectionType: CollectionEditorViewModel.CollectionType,
        sheetPresentMode: Binding<CollectionEditorViewUI.SheetPresentMode?>
    ) {
        self.originalContent = originalContent
        self._content = content
        self.cluster = cluster
        self._sheetPresentMode = sheetPresentMode
        self._collectionType = State(initialValue: collectionType)
    }
    
    func close() {
        sheetPresentMode = nil
    }
    
    func save(newContent: String) async {
        do {
            if collectionType == .lyrics {
                let numberOfSheetsOriginal = try await lyricsUseCase.buildSheetsModels(from: originalContent, cluster: cluster).count
                let numberOfSheetsNew = try await lyricsUseCase.buildSheetsModels(from: newContent, cluster: cluster).count
                if numberOfSheetsOriginal != 0 && (numberOfSheetsNew != numberOfSheetsOriginal) {
                    showingNumberOfSheetsError.toggle()
                } else {
                    content = newContent
                    sheetPresentMode = nil
                }
            } else {
                content = newContent
                sheetPresentMode = nil
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
}

struct LyricsOrBibleStudyInputViewUI: View {
    
    @ObservedObject var viewModel: LyricsOrBibleStudyInputViewModel
    @State var changedContent: String = ""

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                TextView(text: $changedContent, textStyle: $viewModel.font)
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle(AppText.NewSong.title)
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button(AppText.Actions.close) {
                                viewModel.close()
                            }
                            .tint(Color(uiColor: themeHighlighted))
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(AppText.Actions.save) {
                                Task {
                                    await viewModel.save(newContent: changedContent)
                                }
                            }
                            .tint(Color(uiColor: themeHighlighted))
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
}

struct LyricsOrBibleStudyInputViewUI_Previews: PreviewProvider {
    @State static var isShowingBibleStudy: CollectionEditorViewUI.SheetPresentMode? = nil
    @State static var content: String = ""
    static var previews: some View {
        LyricsOrBibleStudyInputViewUI(viewModel: LyricsOrBibleStudyInputViewModel(originalContent: "", content: $content, cluster: .makeDefault()!, font: .callout, collectionType: .lyrics, sheetPresentMode: $isShowingBibleStudy))
    }
}
