//
//  MusicDownloadButtonViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class MusicDownloadButtonViewModel: ObservableObject {
    
    @Published var error: LocalizedError? = nil
    @Published private(set) var showingLoader = false
    
    @State private var collection: ClusterCodable
    
    init(collection: ClusterCodable) {
        self._collection = State(initialValue: collection)
    }
    
    func downloadMusic(manager: MusicDownloadManager) async {
        showingLoader = true
        do {
            try await manager.downloadMusicFor(collection: collection)
            showingLoader = false
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func isDownloading(manager: MusicDownloadManager) async -> Bool {
        await manager.isDownloading(for: collection)
    }
    
}

struct MusicDownloadButtonViewUI: View {
    
    @State private var viewModel: MusicDownloadButtonViewModel
    @EnvironmentObject private var musicDownloadManager: MusicDownloadManager
    @State private var showingDownloading = false
    
    init(collection: ClusterCodable) {
        self._viewModel = State(initialValue: MusicDownloadButtonViewModel(collection: collection))
    }
    
    var body: some View {
        Button {
            Task {
                Task {
                    await viewModel.downloadMusic(manager: musicDownloadManager)
                }
            }
        } label: {
            HStack {
                Image("DownloadIcon")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(!showingDownloading ? .white : .black.opacity(0.8))
                    .frame(width: 30, height: 30)
                    .opacity(!showingDownloading ? 1 : 0)
                    .overlay {
                        if showingDownloading {
                            ProgressView()
                        }
                    }
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            .background(Color(uiColor: !showingDownloading ? .softBlueGrey : .clear))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .tint(.white)
        .onAppear {
            Task {
                showingDownloading = await viewModel.isDownloading(manager: musicDownloadManager)
            }
        }
        .onChange(of: viewModel.showingLoader) { newValue in
            showingDownloading = newValue
        }
    }
}

struct MusicDownloadButtonUI_Previews: PreviewProvider {
    @State static var viewModel = CollectionsViewModel()
    static var previews: some View {
        MusicDownloadButtonViewUI(collection: .makeDefault()!)
    }
}
