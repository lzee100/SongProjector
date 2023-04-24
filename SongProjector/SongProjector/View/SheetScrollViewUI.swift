//
//  SheetScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct SheetScrollViewUI: View {
    
    @State private var frames: [CGRect] = []
    @ObservedObject private(set) var songServiceModel: WrappedStruct<SongServiceUI>
    @State private var nextSelectedSong: SongObjectUI? = nil
    
    let isSelectable: Bool
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if !songServiceModel.item.songs.isEmpty {
            GeometryReader { ruler in
                
                ScrollViewReader { value in
                    ScrollView(isCompactOrVertical(viewSize: ruler.size) ? .vertical : .horizontal) {
                        if isCompactOrVertical(viewSize: ruler.size) {
                            VStack(spacing: 10) {
                                scrollViewItemsPortrait(viewSize: ruler.size)
                            }
                        } else {
                            HStack(spacing: 10) {
                                scrollViewItemsLandscape(viewSize: ruler.size)
                            }
                        }
                    }
                    .coordinateSpace(name: "container")
                    .onPreferenceChange(FramePreference.self, perform: {
                        frames = $0
                    })
                    .ignoresSafeArea(.all)
                    .onChange(of: songServiceModel.item.selectedSheetId) { newValue in
                        guard let sheetIndex = songServiceModel.item.selectedSheetIndex else { return }
                        let selectionIndex = songServiceModel.item.getSheetIndexWithSongIndexAddedIfNeeded(sheetIndex)
                        withAnimation {
                            value.scrollTo(selectionIndex, anchor: .center)
                        }
                    }
                }
                
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder func scrollViewItemsLandscape(viewSize: CGSize) -> some View {
        ForEach(Array(songServiceModel.item.songs.enumerated()), id: \.offset) { index, songObject in
            Group {
                Section {
                    if let selectedSong = songServiceModel.item.selectedSong,  songObject.cluster.id == selectedSong.id {
                        ForEach(Array(selectedSong.sheets.enumerated()), id: \.offset) { sheetIndex, sheet in
                            SheetUIHelper.sheet(viewSize: viewSize, ratioOnHeight: true, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: false, showSelectionCover: true)
                                .id(index + sheetIndex)
                        }
                    }
                } header: {
                    SongServiceSectionViewUI(superViewSize: viewSize, selectedSong: $songServiceModel.item.selectedSong, song: songObject)
                        .sticky(frames, alignment: .horizontal)
                        .onTapGesture {
//                            withAnimation {
                                songServiceModel.item.selectedSong = songServiceModel.item.selectedSong?.id == songObject.id ? nil : songObject
//                            }
                        }
                        .id(index)
                }
            }
        }
    }
    
    @ViewBuilder func scrollViewItemsPortrait(viewSize: CGSize) -> some View {
        ForEach(Array(songServiceModel.item.sectionedSongs.enumerated()), id: \.offset) { offset, songObjectsPerSection in
            VStack(spacing: 10) {
                ForEach(Array(songObjectsPerSection.enumerated()), id: \.offset) { index, songObject in
                    VStack(spacing: 10) {
                        sectionedItemsFor(viewSize: viewSize, index: index, songObject: songObject)
                    }
                }
            }
            .portraitSectionBackgroundFor(viewSize: viewSize)
        }
    }
    
    @ViewBuilder func sectionedItemsFor(viewSize: CGSize, index: Int, songObject: SongObjectUI) -> some View {
        SongServiceSectionViewUI(superViewSize: viewSize, selectedSong: $songServiceModel.item.selectedSong, song: songObject)
            .sticky(frames, alignment: .horizontal)
            .onTapGesture {
                songServiceModel.item.selectedSong = songServiceModel.item.selectedSong?.id == songObject.id ? nil : songObject
            }
            .id(index)
        
        if let selectedCluster = songServiceModel.item.selectedSong?.cluster,  songObject.cluster.id == selectedCluster.id {
            listViewItems(viewSize: viewSize)
        }
    }
        
    @ViewBuilder func listViewItems(viewSize: CGSize) -> some View {
        if let selectedSong = songServiceModel.item.selectedSong {
            VStack(spacing: 0) {
                let sheets = Array(selectedSong.sheets.enumerated())
                ForEach(sheets, id: \.offset) { index, sheet in
                    HStack() {
                        Text(sheet.title ?? "")
                            .foregroundColor(songServiceModel.item.selectedSheetId == sheet.id ? Color(uiColor: .softBlueGrey) : .black)
                            .lineLimit(2)
                            .font(.title)
                            .padding()
                            .padding([.leading], 30)
                        Spacer()
                    }
                    .background(Color(uiColor: .whiteColor))
                    .onTapGesture {
                        guard let selectedSong = songServiceModel.item.selectedSong?.cluster else { return }
                        guard selectedSong.time == 0 && !selectedSong.isTypeSong else { return }
                        songServiceModel.item.selectedSheetId = sheet.id
                    }
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
        viewSize.width < viewSize.height || horizontalSizeClass == .compact
    }

}

struct SheetScrollViewUI_Previews: PreviewProvider {
    @State static var songService = WrappedStruct(withItem: SongServiceUI(songs: []))

    static var previews: some View {
        SheetScrollViewUI(songServiceModel: songService, isSelectable: true)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}

struct PortraitSectionBackground: ViewModifier {
    
    var viewSize: CGSize
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        if isCompactOrVertical(viewSize: viewSize) {
            content
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 25, trailing: 10))
                .background(.white.opacity(0.2))
                .cornerRadius(10)
        } else {
            content
        }
    }
    
    private func isCompactOrVertical(viewSize: CGSize) -> Bool {
        viewSize.width < viewSize.height || horizontalSizeClass == .compact
    }

}
extension View {
    func portraitSectionBackgroundFor(viewSize: CGSize) -> some View {
        modifier(PortraitSectionBackground(viewSize: viewSize))
    }
}
