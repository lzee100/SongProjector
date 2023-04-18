//
//  PageView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct SheetDisplayerPageView: View {
    
    @State private var screenSize: CGSize = .zero
    @State var offset: CGFloat = 0
    @EnvironmentObject var songService: SongService
    @Binding var selectedSong: SongObject?
    @Binding var selectedSheet: VSheet?
    @State var didScrollWithOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            OffsetPageView(offset: $offset, didScrollWithOffset: $didScrollWithOffset, selectedSong: $selectedSong) {
                
                HStack(spacing: 0) {
                    
                    ForEach(getSheets()) { sheet in
                        VStack() {
//                            TitleContentViewUI(position: 0, scaleFactor: getScaleFactor(width: proxy.size.width), selectedSheet: $songService.selectedSheet, sheet: sheet, sheetTheme: VTheme(), showSelectionCover: false)
//                                .tag(sheet)
//                                .frame(width: proxy.size.width, height: getSizeWith(width: proxy.size.width).height, alignment: .center)
                            Spacer()
                        }
                        .frame(width: proxy.size.width)
                    }
                }
            }
            .onAppear {
                self.screenSize = proxy.size
            }
            .onChange(of: songService.selectedSheet) { newValue in
                guard let newSheet = newValue, let selectedSong = songService.selectedSong, let songIndex = songService.songs.firstIndex(of: selectedSong), let sheetindex = songService.selectedSong?.sheets.firstIndex(of: newSheet) else { return }
                let correctedSongIndex = Int(songIndex)
                let correctedSheetIndex = Int(sheetindex)
                offset = CGFloat((correctedSongIndex + correctedSheetIndex))  * proxy.size.width
            }
            .onChange(of: didScrollWithOffset) { newValue in
                selectSheetFor(Int(newValue), screenWidth: Int(screenSize.width))
            }
        }
    }
    
    func sheetsCount() -> Int {
        let selectedSong = songService.selectedSong == nil ? 0 : 1
        let selectedSongSheetCount = songService.selectedSong?.sheets.count ?? 0
        return (songService.songs.count - selectedSong) + selectedSongSheetCount
    }
    
    func getSheets() -> [VSheet] {
        let songSheets: [[VSheet]] = songService.songs.compactMap { songObject in
            if selectedSong == nil {
                return []
            } else if songObject.cluster.id == songService.selectedSong?.cluster.id {
                return songObject.cluster.hasSheets
            } else {
                return [songObject.cluster.hasSheets.first].compactMap({ $0 })
            }
        }
        return songSheets.flatMap { $0 }
    }
    
    func selectSheetFor(_ offset: Int, screenWidth: Int) -> some View {
        guard let selectedSong = songService.selectedSong, let songIndex = songService.songs.firstIndex(of: selectedSong) else { return EmptyView() }
            var currentOffset: Int = 0
            var selectedSheet: VSheet? = nil
            var sheetIndex: Int = 0
            var isDone = false
            repeat {
                if (currentOffset..<(currentOffset + screenWidth)).contains(offset) {
                    sheetIndex = sheetIndex - songIndex
                    if sheetIndex < 0, (songIndex - 1) >= 0 {
                        self.selectedSong = songService.songs[songIndex - 1]
                    } else if sheetIndex >= (songService.selectedSong?.cluster.hasSheets.count ?? 0), songIndex + 1 <= songService.songs.count {
                        songService.selectedSong = songService.songs[songIndex + 1]
                    } else {
                        
                        selectedSheet = songService.selectedSong?.cluster.hasSheets[sheetIndex]
                        if selectedSheet != self.selectedSheet {
                            self.selectedSheet = selectedSheet
                        }
                    }
                    isDone = true
                } else {
                    sheetIndex += 1
                    currentOffset += screenWidth
                }
            } while !isDone
        
        return EmptyView()
    }
    
}

struct SheetDisplayerPageView_Previews: PreviewProvider {
    @State private static var songService = makeSongService(true)
    static var previews: some View {
        PageViewContentView(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet)
            .environmentObject(songService)
    }
}
