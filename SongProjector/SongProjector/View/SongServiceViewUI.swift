//
//  SongServiceUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import UIKit

struct SongServiceViewUI: View {
    
    let dismiss: (() -> Void)
    private let alignment: Sticky.Alignment
    @EnvironmentObject private var soundPlayer: SoundPlayer2
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var selectedSheet: String?
    @State var isUserInteractionEnabledForBeamer = true
    @State var showingMixerView = false
    @State private var soundAndSheetPlayer: SoundWithSheetPlayer?
    @State private var showingSongServiceEditor = false
//    @State var songService: WrappedStruct<SongServiceUI>
    @ObservedObject var songService: WrappedStruct<SongServiceUI>

    init(songService: WrappedStruct<SongServiceUI>, dismiss: @escaping (() -> Void), alignment: Sticky.Alignment = .horizontal) {
//        self._songService = State(initialValue: songService)
        self._songService = ObservedObject(initialValue: songService)
        self.dismiss = dismiss
        self.alignment = alignment
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { ruler in
                VStack(alignment: .center, spacing: 0) {
                    if songService.item.sectionedSongs.count != 0 {
                        BeamerPreviewUI(songService: songService)
                            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
                            .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
                            .allowsHitTesting(isUserInteractionEnabledForBeamer)
                    } else {
                        RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .black1))
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
                                        Text(AppText.SongService.startNew)
                                            .styleAs(font: .xxNormal, color: .white.opacity(0.5))
                                            .shadow(color: .white.opacity(0.3), radius: 2)
                                    }
                                }
                            }
                    }
                    HStack {
                        Spacer()
                        Button {
                            showingMixerView.toggle()
                        } label: {
                            Image("Mixer")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .padding([.top, .bottom])
                        }
                        .sheet(isPresented: $showingMixerView, content: {
                            ZStack {
                                Color.black.opacity(0.95).ignoresSafeArea(.all)
                                MixerViewUI()
                                    .presentationDetents([.height(400)])
                                    .background(.clear)
                            }
                        })
                        Spacer()
                    }
                    Spacer()
                    
                    SheetScrollViewUI(songServiceModel: songService, superViewSize: ruler.size, isSelectable: true)
                        .frame(maxWidth: isCompactOrVertical(ruler: ruler) ? (ruler.size.width * 0.7) : .infinity, maxHeight: isCompactOrVertical(ruler: ruler) ? .infinity : 220)
                }
                .background(.black)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle(AppText.SongService.title)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if songService.item.sectionedSongs.count > 0 {
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
        }
        .onAppear {
            soundAndSheetPlayer = SoundWithSheetPlayer(soundPlayer: soundPlayer) { id in
                self.songService.item.selectedSheetId = id
            }
            let songService: [SongServiceSettings] = DataFetcher().getEntities(moc: moc)
            if let songService = songService.first, let cod = SongServiceSettingsCodable(managedObject: songService, context: moc) {
                let service = SongServiceGeneratorUseCase().generate(for: cod)
                self.songService.item.set(sectionedSongs: service)
            }
        }
        .onChange(of: selectedSheet) { newValue in
            songService.item.selectedSheetId = newValue
        }
        .onChange(of: songService.item.selectedSong) { newValue in
            guard let selectedSong = newValue else {
                isUserInteractionEnabledForBeamer = true
                return
            }
            if selectedSong.cluster.hasLocalMusic || selectedSong.cluster.time > 0 {
                isUserInteractionEnabledForBeamer = false
            } else {
                isUserInteractionEnabledForBeamer = true
            }
        }
        .onChange(of: songService.item.selectedSong) { song in
            soundAndSheetPlayer?.stop()
            guard let song, let soundAndSheetPlayer else {
                return
            }
            guard song.cluster.time > 0 || song.cluster.hasLocalMusic else {
                return
            }
            soundAndSheetPlayer.play(song: song)
        }
        .sheet(isPresented: $showingSongServiceEditor) {
            SongServiceEditorViewUI(songService: songService, showingSongServiceEditorViewUI: $showingSongServiceEditor)
        }
    }
    
    func isCompactOrVertical(ruler: GeometryProxy) -> Bool {
        ruler.size.width < ruler.size.height || horizontalSizeClass == .compact
    }
}

struct SongServiceUI_Previews: PreviewProvider {
    @State static var songService = WrappedStruct(withItem: SongServiceUI())
    static var previews: some View {
        SongServiceViewUI(songService: songService, dismiss: {})
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewInterfaceOrientation(.portrait)
    }
}
