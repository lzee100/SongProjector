//
//  MusicDownloadButtonViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct MusicDownloadButtonViewUI: View {
    
    @State private var fetchMusicProgress: RequesterResult = .idle
    @ObservedObject private var fetchMusicUseCase: FetchMusicUseCase
    
    init(fetchMusicUseCase: FetchMusicUseCase) {
        self.fetchMusicUseCase = fetchMusicUseCase
    }
    
    var body: some View {
        Button {
            fetchMusicUseCase.fetch()
        } label: {
            HStack {
                Image("DownloadIcon")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(fetchMusicUseCase.progress == .idle ? .white : .black.opacity(0.8))
                    .frame(width: 30, height: 30)
                    .opacity(fetchMusicUseCase.progress == .idle ? 1 : 0)
                    .overlay {
                        if fetchMusicUseCase.progress != .idle {
                            CircleProgressViewUI(
                                fetchMusicUseCase: fetchMusicUseCase,
                                lineWidth: 4
                            )
                        }
                    }
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            .background(Color(uiColor: fetchMusicUseCase.progress == .idle ? .softBlueGrey : .clear))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .tint(.white)
    }
}

struct MusicDownloadButtonUI_Previews: PreviewProvider {
    static var previews: some View {
        MusicDownloadButtonViewUI(fetchMusicUseCase: FetchMusicUseCase(cluster: .makeDefault()!))
    }
}
