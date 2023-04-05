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
    @EnvironmentObject var songService: SongService
    @Binding var selectedSong: SongObject?
    @Binding var selectedSheet: VSheet?
    @State var isSongSelected: SongObject?
    
    let isSelectable: Bool
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if !songService.songs.isEmpty {
            GeometryReader { ruler in
                
                ScrollViewReader { value in
                    ScrollView(isCompactOrVertical(viewSize: ruler.size) ? .vertical : .horizontal) {
                        if isCompactOrVertical(viewSize: ruler.size) {
                            VStack(spacing: 10) {
                                scrollViewItems(viewSize: ruler.size)
                            }
                        } else {
                            HStack(spacing: 10) {
                                scrollViewItems(viewSize: ruler.size)
                            }
                        }
                    }
                    .coordinateSpace(name: "container")
                    .onPreferenceChange(FramePreference.self, perform: {
                        frames = $0
                    })
                    .ignoresSafeArea(.all)
                    .onChange(of: selectedSheet) { newValue in
                        guard let selectionIndex = getIndexForSelection() else { return }
                        withAnimation {
                            value.scrollTo(selectionIndex, anchor: .center)
                        }
                    }
                }
                
            }
            .onChange(of: isSongSelected) { newValue in
                withAnimation(.easeOut) {
                    selectedSong = selectedSong?.cluster.id == isSongSelected?.cluster.id ? nil : isSongSelected
                }
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder func scrollViewItems(viewSize: CGSize) -> some View {
        ForEach(Array(songService.songs.enumerated()), id: \.offset) { index, songObject in
            Section {
                if let selectedCluster = selectedSong?.cluster,  songObject.cluster.id == selectedCluster.id {
                    if isCompactOrVertical(viewSize: viewSize) {
                        listViewItems(viewSize: viewSize)
                    } else {
                        ForEach(Array(selectedCluster.hasSheets.enumerated()), id: \.offset) { sheetIndex, sheet in
                            TitleContentViewUI(position: sheetIndex, scaleFactor: getScaleFactor(width: getSizeWith(height: viewSize.height).width), selectedSheet: $selectedSheet, sheet: sheet as! VSheetTitleContent, sheetTheme: (sheet as! VSheetTitleContent).hasTheme ?? selectedSong?.cluster.hasTheme(moc: moc) ?? VTheme(), showSelectionCover: true)
                                .id(index + sheetIndex)
                        }
                    }
                }
            } header: {
                SongServiceSectionViewUI(superViewSize: viewSize, selectedSong: $isSongSelected, song: songObject)
                    .sticky(frames, alignment: .horizontal)
                    .onTapGesture {
                        isSongSelected = selectedSong?.cluster.id == songObject.cluster.id ? nil : songObject
                    }
                    .id(index)
            }
        }
    }
    
    @ViewBuilder func listViewItems(viewSize: CGSize) -> some View {
        if let selectedCluster = selectedSong?.cluster {
            VStack(spacing: 0) {
                let sheets = Array(selectedCluster.hasSheets.compactMap { $0 as? VSheetTitleContent }.enumerated())
                ForEach(sheets, id: \.offset) { index, sheet in
                    HStack() {
                        Text(sheet.title ?? "")
                            .foregroundColor(self.selectedSheet?.id == sheet.id ? Color(uiColor: .softBlueGrey) : .black)
                            .lineLimit(2)
                            .font(.title)
                            .padding()
                            .padding([.leading], 30)
                        Spacer()
                    }
                    .background(Color(uiColor: .whiteColor))
                    .onTapGesture {
                        guard let selectedSong = songService.selectedSong?.cluster else { return }
                        guard selectedSong.time == 0 && !selectedSong.isTypeSong else { return }
                        songService.selectedSheet = sheet
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
    
    private func getIndexForSelection() -> Int? {
        guard let songIndex = songService.selectedSongIndex, let selectedSheetIndex = selectedSong?.cluster.hasSheets.firstIndex(where: { $0.id == selectedSheet?.id }) else { return nil }
        return songIndex + selectedSheetIndex
    }

}

struct SheetScrollViewUI_Previews: PreviewProvider {
    @State static var songService = makeSongService()
    
    static var previews: some View {
        SheetScrollViewUI(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet, isSelectable: true)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
            .environmentObject(songService)
    }
}
