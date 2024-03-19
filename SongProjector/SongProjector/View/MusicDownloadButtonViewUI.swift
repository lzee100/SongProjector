//
//  MusicDownloadButtonViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

//@MainActor class MusicDownloadButtonViewModel: ObservableObject {
//    
//    @Published var error: LocalizedError? = nil
//    @Published var showingLoader = false
//    
//    private(set) var collection: ClusterCodable
//    
//    init(collection: ClusterCodable) {
//        self.collection = collection
//    }
//    
//    func downloadMusic(manager: MusicDownloadManager) async {
//        showingLoader = true
//        do {
//            guard await !manager.isDownloading(for: collection) else { return }
//            try await manager.downloadMusicFor(collection: collection)
//            showingLoader = false
//        } catch {
//            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
//        }
//    }
//    
//    func isDownloading(manager: MusicDownloadManager) async -> Bool {
//        await manager.isDownloading(for: collection)
//    }
//}

struct MusicDownloadButtonViewUI: View {
    
    let collection: ClusterCodable
    @Environment(MusicDownloadManager.self) private var musicDownloadManager
    @State var error: LocalizedError?

    var body: some View {
        Button {
            Task {
                do {
                    try await musicDownloadManager.downloadMusicFor(collection: collection)
                    error = nil
                } catch {
                    self.error = error.forcedLocalizedError
                }
            }
        } label: {
            ZStack {
                    GIFView(location: Bundle.main.url(forResource: "Loader", withExtension: "gif")!)
                        .colorInvert()
                        .frame(width: 30, height: 30)
                        .opacity(musicDownloadManager.isDownloading(for: collection) ? 1 : 0)
                    Image("DownloadIcon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(musicDownloadManager.isDownloading(for: collection) ? .clear : .white)
                        .frame(width: 30, height: 30)
                        .opacity(musicDownloadManager.isDownloading(for: collection) ? 0 : 1)
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            .background(Color(uiColor: musicDownloadManager.isDownloading(for: collection) ? .clear : .softBlueGrey))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .tint(.white)
    }
}

struct MusicDownloadButtonUI_Previews: PreviewProvider {
    @State static var viewModel = CollectionsViewModel(tagSelectionModel: TagSelectionModel(mandatoryTagIds: []), customSelectedSongsForSongService: [], customSelectionDelegate: nil)
    static var previews: some View {
        MusicDownloadButtonViewUI(collection: .makeDefault()!)
    }
}
