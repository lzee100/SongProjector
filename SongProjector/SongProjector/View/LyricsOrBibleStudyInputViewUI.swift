//
//  LyricsOrBibleStudyInputViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct LyricsOrBibleStudyInputViewUI: View {
    
    @Binding var content: String
    @State private var font: UIFont.TextStyle = .body
    private let initialContent: String
    @Binding var isShowingLyricsOrBibleStudyInputView: Bool
    
    init(content: Binding<String>, isShowingLyricsOrBibleStudyInputView: Binding<Bool>) {
        self._content = content
        self._isShowingLyricsOrBibleStudyInputView = isShowingLyricsOrBibleStudyInputView
        self.initialContent = content.wrappedValue
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                TextView(text: $content, textStyle: $font)
                    .portraitSectionBackgroundFor(viewSize: proxy.size)
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle(AppText.NewSong.title)
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button(AppText.Actions.close) {
                                content = initialContent
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(AppText.Actions.save) {
                                self.isShowingLyricsOrBibleStudyInputView.toggle()
                            }
                        }
                    })
            }
        }
    }
}

struct LyricsOrBibleStudyInputViewUI_Previews: PreviewProvider {
    @State static var isShowingBibleStudy = false
    @State static var content: String = ""
    static var previews: some View {
        LyricsOrBibleStudyInputViewUI(content: $content, isShowingLyricsOrBibleStudyInputView: $isShowingBibleStudy)
    }
}
