//
//  SheetScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct SheetScrollViewUI: View {
    
    @State private var orientation: UIDeviceOrientation = .unknown
    @State private var frames: [CGRect] = []
    @ObservedObject private(set) var songServiceModel: SongServiceUI
    @State private var nextSelectedSong: SongObjectUI? = nil
    @State private var defaultTheme: ThemeCodable?
    var superViewSize: CGSize
    
    let isSelectable: Bool
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if !songServiceModel.songs.isEmpty {
            GeometryReader { ruler in
                
                ScrollViewReader { value in
                    ScrollView(isCompactOrVertical(viewSize: superViewSize) ? .vertical : .horizontal) {
                        if isCompactOrVertical(viewSize: superViewSize) {
                            VStack(spacing: 10) {
                                scrollViewItemsPortrait(viewSize: superViewSize)
                            }
                        } else {
                            HStack(spacing: 10) {
                                scrollViewItemsLandscape()
                            }
                        }
                    }
                    .coordinateSpace(name: "container")
                    .onPreferenceChange(FramePreference.self, perform: {
                        frames = $0
                    })
                    .onChange(of: songServiceModel.selectedSheetId) { newValue in
                        guard let selectedSheetId = songServiceModel.selectedSheetId else { return }
                        
                        withAnimation {
                            value.scrollTo(selectedSheetId, anchor: .center)
                        }
                    }
                    .onRotate { orientation in
                        self.orientation = orientation
                    }
                }
            }
            .onAppear {
                Task {
                    let defaultTheme = try? await CreateThemeUseCase().create()
                    await MainActor.run {
                        self.defaultTheme = defaultTheme
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder func scrollViewItemsLandscape() -> some View {
        ForEach(Array(songServiceModel.sectionedSongs.enumerated()), id: \.offset) { offset, songObjectsPerSection in
            VStack {
                Text(songObjectsPerSection.title)
                    .styleAs(font: .xNormalBold, color: .white)
                HStack(spacing: 10) {
                    ForEach(Array(songObjectsPerSection.songs.enumerated()), id: \.offset) { index, songObject in
                        Section {
                            if let selectedSong = songServiceModel.selectedSong,  songObject.cluster.id == selectedSong.id {
                                HStack {
                                    ForEach(Array(songServiceModel.selectedSongSheetViewModels.enumerated()), id: \.offset) { sheetIndex, model in
                                        Button {
                                            songServiceModel.selectedSheetId = model.id
                                        } label: {
                                            SheetUIHelper.sheet(sheetViewModel: model, isForExternalDisplay: false)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8).fill(.black.opacity(songServiceModel.selectedSheetId == model.id ? 0 : 0.4))
                                                )
                                        }
                                        .id(model.id)
                                        .disabled(!songServiceModel.isSheetSelectable(sheetViewModel: model))
                                    }
                                }
                            }
                        } header: {
                            SongServiceSectionViewUI(superViewSize: superViewSize, selectedSong: $songServiceModel.selectedSong, song: songObject)
                                .sticky(frames, alignment: .horizontal)
                                .onTapGesture {
                                    songServiceModel.selectedSong = songServiceModel.selectedSong?.id == songObject.id ? nil : songObject
                                }
                                .id(songObject.id)
                        }
                    }
                }
            }
            .styleAsSectionBackground(edgeInsets: EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
        }
    }
    
    @ViewBuilder func scrollViewItemsPortrait(viewSize: CGSize) -> some View {
        ForEach(Array(songServiceModel.sectionedSongs.enumerated()), id: \.offset) { offset, songObjectsPerSection in
            VStack(spacing: 10) {
                Text(songObjectsPerSection.title)
                    .styleAs(font: .xNormalBold, color: .white)
                ForEach(Array(songObjectsPerSection.songs.enumerated()), id: \.offset) { index, songObject in
                    VStack(spacing: 10) {
                        sectionedItemsFor(viewSize: viewSize, index: index, songObject: songObject)
                    }
                }
            }
            .styleAsSectionBackground()
        }
    }
    
    @ViewBuilder func sectionedItemsFor(viewSize: CGSize, index: Int, songObject: SongObjectUI) -> some View {
        SongServiceSectionViewUI(superViewSize: viewSize, selectedSong: $songServiceModel.selectedSong, song: songObject)
            .sticky(frames, alignment: .horizontal)
            .onTapGesture {
                songServiceModel.selectedSong = songServiceModel.selectedSong?.id == songObject.id ? nil : songObject
            }
            .id(songObject.id)
        
        if let selectedCluster = songServiceModel.selectedSong?.cluster,  songObject.cluster.id == selectedCluster.id {
            listViewItems(viewSize: viewSize)
        }
    }
    
    @ViewBuilder func listViewItems(viewSize: CGSize) -> some View {
        if let selectedSong = songServiceModel.selectedSong {
            VStack(spacing: 0) {
                let sheets = Array(selectedSong.sheets.enumerated())
                ForEach(sheets, id: \.offset) { index, sheet in
                    HStack() {
                        Text(sheet.title ?? "")
                            .foregroundColor(songServiceModel.selectedSheetId == sheet.id ? Color(uiColor: .softBlueGrey) : Color(uiColor: .blackColor).opacity(0.8))
                            .lineLimit(2)
                            .styleAs(font: songServiceModel.selectedSheetId == sheet.id ? .xNormalBold : .xNormal)
                            .padding()
                        Spacer()
                    }
                    .background(Color(uiColor: .whiteColor))
                    .onTapGesture {
                        guard let selectedSong = songServiceModel.selectedSong?.cluster else { return }
                        guard selectedSong.time == 0 && !selectedSong.isTypeSong else { return }
                        songServiceModel.selectedSheetId = sheet.id
                    }
                    .id(sheet.id)
                    Divider()
                }
            }
            .background(Color(uiColor: .whiteColor))
            .cornerRadius(10)
        } else {
            EmptyView()
        }
    }
    
    private func isCompactOrVertical(viewSize: CGSize) -> Bool {
        return viewSize.width < viewSize.height || horizontalSizeClass == .compact
    }
}

struct SheetScrollViewUI_Previews: PreviewProvider {
    @State static var songService = SongServiceUI(songs: [])
    
    static var previews: some View {
        SheetScrollViewUI(songServiceModel: songService, superViewSize: .zero, isSelectable: true)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}

struct SectionBackgroundModifier: ViewModifier {
    
    var color: Color = .white
    var edgeInsets: EdgeInsets
    
    func body(content: Content) -> some View {
        content
            .padding(edgeInsets)
            .background(color.opacity(0.2))
            .cornerRadius(10)
    }
    
}
extension View {
    func styleAsSectionBackground(color: Color = .white, edgeInsets: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 25, trailing: 10)) -> some View {
        modifier(SectionBackgroundModifier(color: color, edgeInsets: edgeInsets))
    }
}
