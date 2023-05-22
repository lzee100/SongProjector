//
//  LyricsOrBibleStudyInputViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

class LyricsOrBibleStudyInputViewModel: ObservableObject {
    
    @Binding var content: String
    @State var cluster: ClusterCodable
    @State var font: UIFont.TextStyle = .body
    @State var collectionType: CollectionEditorViewModel.CollectionType
    @Published var showingNumberOfSheetsError = false
    @Binding var isShowingLyricsOrBibleStudyInputView: Bool
    
    init(content: Binding<String>, cluster: ClusterCodable, font: UIFont.TextStyle, collectionType: CollectionEditorViewModel.CollectionType, isShowingLyricsOrBibleStudyInputView: Binding<Bool>) {
        self._content = content
        self.cluster = cluster
        self._isShowingLyricsOrBibleStudyInputView = isShowingLyricsOrBibleStudyInputView
        self._collectionType = State(initialValue: collectionType)
    }
    
    func close() {
        isShowingLyricsOrBibleStudyInputView.toggle()
    }
    
    func save(newContent: String) {
        if collectionType == .lyrics {
            let numberOfSheetsOriginal = GenerateLyricsSheetContentUseCase.buildSheets(fromText: newContent, cluster: cluster).count
            let numberOfSheetsNew = GenerateLyricsSheetContentUseCase.buildSheets(fromText: content, cluster: cluster).count
            if numberOfSheetsNew != numberOfSheetsOriginal {
                showingNumberOfSheetsError.toggle()
            } else {
                content = newContent
                isShowingLyricsOrBibleStudyInputView.toggle()
            }
        } else {
            content = newContent
            isShowingLyricsOrBibleStudyInputView.toggle()
        }
    }
}

struct LyricsOrBibleStudyInputViewUI: View {
    
    @StateObject var viewModel: LyricsOrBibleStudyInputViewModel
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
                                viewModel.save(newContent: changedContent)
                            }
                            .tint(Color(uiColor: themeHighlighted))
                        }
                    })
                    .alert(Text(AppText.CustomSheets.universalSongEditErrorMessage), isPresented: $viewModel.showingNumberOfSheetsError) {
                        Button(AppText.Actions.ok, role: .cancel) {
                        }
                    }
                    .onAppear {
                        changedContent = viewModel.content
                    }
            }
        }
    }
}

struct LyricsOrBibleStudyInputViewUI_Previews: PreviewProvider {
    @State static var isShowingBibleStudy = false
    @State static var content: String = ""
    static var previews: some View {
        LyricsOrBibleStudyInputViewUI(viewModel: LyricsOrBibleStudyInputViewModel(content: $content, cluster: .makeDefault()!, font: .callout, collectionType: .lyrics, isShowingLyricsOrBibleStudyInputView: $isShowingBibleStudy))
    }
}
