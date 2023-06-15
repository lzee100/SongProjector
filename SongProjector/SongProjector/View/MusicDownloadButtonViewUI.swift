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
    @Published var showingLoader = false
    
    private(set) var collection: ClusterCodable
    
    init(collection: ClusterCodable) {
        self.collection = collection
    }
    
    func downloadMusic(manager: MusicDownloadManager) async {
        showingLoader = true
        do {
            guard await !manager.isDownloading(for: collection) else { return }
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
    
    @ObservedObject private var viewModel: MusicDownloadButtonViewModel
    @EnvironmentObject private var musicDownloadManager: MusicDownloadManager
    
    init(collection: ClusterCodable) {
        self._viewModel = ObservedObject(initialValue: MusicDownloadButtonViewModel(collection: collection))
    }
    
    var body: some View {
        Button {
            Task {
                await viewModel.downloadMusic(manager: musicDownloadManager)
            }
        } label: {
            HStack {
                Image("DownloadIcon")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(viewModel.showingLoader ? .clear : .white)
                    .frame(width: 30, height: 30)
                    .overlay {
                        if viewModel.showingLoader {
                            ProgressView()
                                .scaleEffect(1.4)
                                .tint(Color(uiColor: .blackColor).opacity(0.8))
                        }
                    }
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            .background(Color(uiColor: viewModel.showingLoader ? .clear : .softBlueGrey))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .tint(.white)
        .onAppear {
            Task {
                let isDownloading = await viewModel.isDownloading(manager: musicDownloadManager)
                await MainActor.run(body: {
                    viewModel.showingLoader = isDownloading
                })
            }
        }
    }
}

struct MusicDownloadButtonUI_Previews: PreviewProvider {
    @State static var viewModel = CollectionsViewModel(tagSelectionModel: TagSelectionModel(mandatoryTags: []), customSelectedSongsForSongService: [], customSelectionDelegate: nil)
    static var previews: some View {
        MusicDownloadButtonViewUI(collection: .makeDefault()!)
    }
}
