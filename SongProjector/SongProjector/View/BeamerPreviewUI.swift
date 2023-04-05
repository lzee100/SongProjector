//
//  BeamerViewUI2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct BeamerPreviewUI: View {
    
    private enum SwipeDirection {
        case left
        case right
        case none
    }
    
    @State private var selection: Int = 0
    @State private var swipeDirection: SwipeDirection = .none
    
    @EnvironmentObject var songService: SongService
    @Binding var selectedSong: SongObject?
    @Binding var selectedSheet: VSheet?
    private let displayerId = "DisplayerView"
    
    var body: some View {
        GeometryReader { screenProxy in
            VStack(){
                TabView(selection: $selection) {
                    getTabView(screenSize: screenProxy.size)
                }
                .coordinateSpace(name: displayerId)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .onChange(of: selection, perform: { newValue in
                    updateSongServiceOnNewIndex(newValue)
                })
                .onChange(of: selectedSheet) { newValue in
                    guard let selectedSongIndex = songService.selectedSongIndex, let selectedSong else { return }
                    selection = selectedSongIndex + (selectedSong.cluster.hasSheets.firstIndex(where: { $0.id == selectedSheet?.id }) ?? 0)
                }
                .onChange(of: selectedSong) { newValue in
                    updateSheetOnNewSong(newValue)
                }
                Text("\(selection)")
                    .foregroundColor(.white)
            }
            
        }
    }
    
    @ViewBuilder private func getTabView(screenSize: CGSize) -> some View {
        ForEach(Array(songService.songs.enumerated()), id: \.offset) { index, songObject in
            
            if songService.selectedSong == nil {
                
                EmptyView()
                
            } else if songObject.cluster.id == selectedSong?.cluster.id {

                ForEach(Array(songObject.cluster.hasSheets.enumerated()), id: \.offset) { sheetIndex, sheet in
                    TitleContentViewUI(position: 0, scaleFactor: getScaleFactor(width: screenSize.width), selectedSheet: $selectedSheet, sheet: sheet, sheetTheme: (sheet as! VSheetTitleContent).hasTheme ?? selectedSong?.cluster.hasTheme(moc: moc) ?? VTheme(), showSelectionCover: false)
                        .tag(getSheetIndexWithSongIndexAddedIfNeeded(sheetIndex))
                }
                
            } else if let sheet = songObject.cluster.hasSheets.first {
            
                TitleContentViewUI(position: 0, scaleFactor: 1, selectedSheet: $songService.selectedSheet, sheet: sheet, sheetTheme: VTheme(), showSelectionCover: false)
                    .tag(getSongIndexWithSheetIndexAddedIfNeeded(index))
                
            } else {
                
                EmptyView()
                
            }
        }
    }
    
    private func getSheetIndexWithSongIndexAddedIfNeeded(_ currentIndex: Int) -> Int {
        print("sheet \(currentIndex + (songService.selectedSongIndex ?? 0))")
        return currentIndex + (songService.selectedSongIndex ?? 0)
    }
    
    private func getSongIndexWithSheetIndexAddedIfNeeded(_ currentIndex: Int) -> Int {
        let addedIndex = currentIndex > (songService.selectedSongIndex ?? 0) ? (selectedSong?.cluster.hasSheets.count ?? 0) - 1 : 0
        print("song \(currentIndex + addedIndex)")
        return currentIndex + addedIndex
    }
    
    private func updateSongServiceOnNewIndex(_ newValue: Int) {
        guard let selectedSongIndex = songService.selectedSongIndex, let selectedSong else { return }
        if newValue >= selectedSongIndex + selectedSong.cluster.hasSheets.count {
            songService.selectedSong = songService.songs[safe: selectedSongIndex + 1]
            selection = selectedSongIndex + 1
        } else if newValue < selectedSongIndex {
            songService.selectedSong = songService.songs[safe: selectedSongIndex - 1]
            selection = selectedSongIndex - 1
        } else {
            songService.selectedSheet = songService.selectedSong?.cluster.hasSheets[safe: newValue - selectedSongIndex]
        }
    }
    
    private func updateSheetOnNewSong(_ selectedSong: SongObject?) {
        guard let selectedSongIndex = songService.selectedSongIndex, selectedSong != nil else {
            selection = -1
            return
        }
        selection = selectedSongIndex
    }
    
}

struct BeamerViewUI2_Previews: PreviewProvider {
    @State static var songService = makeSongService(true)
    
    static var previews: some View {
        let demoCluster = VCluster()
        let demoSheet = VSheetTitleContent()
        demoSheet.title = "Test title Leo"
        demoSheet.content = "Test content Leo"
        demoCluster.hasSheets = [demoSheet]
        return BeamerPreviewUI(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.landscapeLeft)
            .environmentObject(songService)
    }
}
