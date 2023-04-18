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
    
    @ViewBuilder func scrollViewItemsLandscape(viewSize: CGSize) -> some View {
        ForEach(Array(songService.songs.enumerated()), id: \.offset) { index, songObject in
            Group {
                Section {
                    if let selectedCluster = selectedSong?.cluster,  songObject.cluster.id == selectedCluster.id {
                        ForEach(Array(selectedCluster.hasSheets.enumerated()), id: \.offset) { sheetIndex, sheet in
                            TitleContentViewUI(displayModel: SheetDisplayViewModel(position: sheetIndex, selectedSheet: $selectedSheet, sheet: sheet, sheetTheme: (sheet as! VSheetTitleContent).hasTheme ?? selectedSong?.cluster.hasTheme(moc: moc) ?? VTheme(), showSelectionCover: true), scaleFactor: getScaleFactor(width: getSizeWith(height: viewSize.height).width), isForExternalDisplay: false)
                                .id(index + sheetIndex)
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
    }
    
    @ViewBuilder func scrollViewItemsPortrait(viewSize: CGSize) -> some View {
        ForEach(Array(songService.songsClusteredPerSection.enumerated()), id: \.offset) { offset, songObjectsPerSection in
            VStack(spacing: 10) {
//                ForEach(Array(songObjectsPerSection.enumerated()), id: \.index) { index, songObject in
//                    VStack(spacing: 10) {
//                        sectionedItemsFor(viewSize: viewSize, index: index, songObject: songObject)
//                    }
//                }
            }
            .portraitSectionBackgroundFor(viewSize: viewSize)
        }
    }
    
    @ViewBuilder func sectionedItemsFor(viewSize: CGSize, index: Int, songObject: SongObject) -> some View {
        SongServiceSectionViewUI(superViewSize: viewSize, selectedSong: $isSongSelected, song: songObject)
            .sticky(frames, alignment: .horizontal)
            .onTapGesture {
                isSongSelected = selectedSong?.cluster.id == songObject.cluster.id ? nil : songObject
            }
            .id(index)
        
        if let selectedCluster = selectedSong?.cluster,  songObject.cluster.id == selectedCluster.id {
            listViewItems(viewSize: viewSize)
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
