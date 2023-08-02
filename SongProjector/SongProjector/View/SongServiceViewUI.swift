//
//  SongServiceUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import UIKit
private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

@MainActor class SongServiceViewModel: ObservableObject {
    
    @Binding var showingSongServiceView: Bool
    
    init(showingSongServiceView: Binding<Bool>) {
        self._showingSongServiceView = showingSongServiceView
    }
    func submitPlayDateFor(_ song: SongObjectUI) async {
        var cluster = song.cluster
        cluster.lastShownAt = Date()
        _ = try? await SubmitUseCase(endpoint: .clusters, requestMethod: .put, uploadObjects: [cluster]).submit()
    }
}

struct SongServiceViewUI: View {
    
    private let alignment: Sticky.Alignment
    @EnvironmentObject private var soundPlayer: SoundPlayer2
    @EnvironmentObject var musicDownloadManager: MusicDownloadManager
    @EnvironmentObject var store: ExternalDisplayConnector
    @State private var collectionCountDown: CollectionCountDown?
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var selectedSheet: String?
    @State var isUserInteractionEnabledForBeamer = true
    @State var showingMixerView = false
    @State private var soundAndSheetPlayer: SoundWithSheetPlayer?
    @State private var showingSongServiceEditor = false
    @State private var countDownValue: Int? = nil
    @StateObject var songService = SongServiceUI()
    @StateObject var viewModel: SongServiceViewModel
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    private let previewSong: ClusterCodable?
    
    init(alignment: Sticky.Alignment = .horizontal, previewSong: ClusterCodable? = nil, showingSongServiceView: Binding<Bool>) {
        self.alignment = alignment
        self.previewSong = previewSong
        self._viewModel = StateObject(wrappedValue: SongServiceViewModel(showingSongServiceView: showingSongServiceView))
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { ruler in
                VStack(alignment: .center, spacing: 0) {
                    if songService.sectionedSongs.count != 0 {
                        HStack {
                            Spacer()
                            BeamerPreviewUI(sendToExternalDisplayUseCase: SendToExternalDisplayUseCase(connector: store), songService: songService)
                                .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
                                .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
                                .allowsHitTesting(isUserInteractionEnabledForBeamer)
                                .overlay {
                                    if let countDownValue {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text("\(countDownValue)")
                                                    .styleAs(font: .xxxLargeBold, color: .white)
                                                    .padding(EdgeInsets(top: 5, leading: 50, bottom: 5, trailing: 50))
                                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                                    .environment(\.colorScheme, .dark)
                                                Spacer()
                                            }
                                            .padding([.bottom], 30)
                                        }
                                    }
                                }
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .almostBlack))
                                .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
                                .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
                                .overlay {
                                    Button {
                                        showingSongServiceEditor.toggle()
                                    } label: {
                                        VStack(spacing: 20) {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .tint(Color(uiColor: themeHighlighted))
                                            Text(AppText.SongService.startNew)
                                                .styleAs(font: .xxNormal, color: .white.opacity(0.5))
                                                .shadow(color: .white.opacity(0.3), radius: 2)
                                        }
                                    }
                                }
                            Spacer()
                        }
                    }
                    Spacer()
                    SheetScrollViewUI(songServiceModel: songService, superViewSize: ruler.size, isSelectable: true)
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom != .phone && orientation.isPortrait ? (ruler.size.width * 0.7) : .infinity, maxHeight: orientation.isPortrait ? .infinity : 220)
                }
                .onRotate { orientation in
                    self.orientation = orientation
                }
                .padding([.bottom], 1)
                .background(.black)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle(AppText.SongService.title)
                .toolbar {
                    
                    if previewSong != nil {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                viewModel.showingSongServiceView = false
                            } label: {
                                Text(AppText.Actions.close)
                                    .tint(Color(uiColor: themeHighlighted))
                            }
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            showingMixerView.toggle()
                        } label: {
                            Image("Mixer")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .tint(Color(uiColor: themeHighlighted))
                        }
                        if songService.sectionedSongs.count > 0 {
                            Button {
                                showingSongServiceEditor.toggle()
                            } label: {
                                Text(AppText.Actions.edit)
                            }
                            .tint(Color(uiColor: themeHighlighted))
                        }
                    }
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .tabBar)
                .toolbarBackground(.black, for: .tabBar)
            }
            .sheet(isPresented: $showingSongServiceEditor) {
                SongServiceEditorViewUI(songService: songService, viewModel: SongServiceEditorModel(songServiceUI: songService), showingSongServiceEditorViewUI: $showingSongServiceEditor)
            }
            .sheet(isPresented: $showingMixerView, content: {
                ZStack {
                    Color(uiColor: .almostBlack).ignoresSafeArea(.all)
                    MixerViewUI()
                        .presentationDetents([.height(400)])
                        .background(.clear)
                }
            })
        }
        .environmentObject(musicDownloadManager)
        .onAppear {
            if let previewSong {
                songService.set(sectionedSongs: [SongServiceSectionWithSongs(title: "", cocList: [.cluster(previewSong)])])
            }
            if collectionCountDown == nil {
                collectionCountDown = CollectionCountDown(countDownDidChange: { countDown in
                    countDownValue = countDown
                })
            }
            soundAndSheetPlayer = SoundWithSheetPlayer(soundPlayer: soundPlayer, collectionCountDown: collectionCountDown!) { id in
                self.songService.selectedSheetId = id
            }
//            Task {
//                let songServiceSettingsCodable = await GetSongServiceSettingsUseCase().fetch()
//                if let songServiceSettingsCodable {
//                    let service = await SongServiceGeneratorUseCase().generate(for: songServiceSettingsCodable)
//                    await MainActor.run {
//                        self.songService.set(sectionedSongs: service)
//                    }
//                }
//            }
        }
        .onChange(of: selectedSheet) { newValue in
            songService.selectedSheetId = newValue
        }
        .onChange(of: songService.selectedSong) { newValue in
            guard let selectedSong = newValue else {
                isUserInteractionEnabledForBeamer = true
                return
            }
            if selectedSong.cluster.hasLocalMusic {
                isUserInteractionEnabledForBeamer = false
            } else {
                isUserInteractionEnabledForBeamer = true
            }
            Task {
                await viewModel.submitPlayDateFor(selectedSong)
            }
        }
        .onChange(of: songService.selectedSong) { song in
            soundAndSheetPlayer?.stop()
            guard let song, let soundAndSheetPlayer else {
                return
            }
            guard song.cluster.time > 0 || song.cluster.hasLocalMusic else {
                return
            }
            soundAndSheetPlayer.play(song: song)
        }
    }
    
    func isCompactOrVertical(ruler: GeometryProxy) -> Bool {
        ruler.size.width < ruler.size.height || horizontalSizeClass == .compact
    }
}

struct SongServiceUI_Previews: PreviewProvider {
    @State static var songService = SongServiceUI()
    @State static var showingSongServiceView = true
    static var previews: some View {
        SongServiceViewUI(showingSongServiceView: $showingSongServiceView)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewInterfaceOrientation(.portrait)
    }
}
