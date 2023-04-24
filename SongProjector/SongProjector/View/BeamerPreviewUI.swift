//
//  BeamerViewUI2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct BeamerPreviewUI: View {
    
    @State private var selection: Int = -1
    @State private var previousSelection: Int = -1
    @ObservedObject var songService: WrappedStruct<SongServiceUI>
    private let displayerId = "DisplayerView"
    
    var body: some View {
        GeometryReader { screenProxy in
            TabView(selection: $selection) {
                getTabView(screenSize: screenProxy.size)
            }
            .coordinateSpace(name: displayerId)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = themeHighlighted
                UIPageControl.appearance().pageIndicatorTintColor = .black.withAlphaComponent(0.2)
            }
            .onDisappear {
                UIPageControl.appearance().currentPageIndicatorTintColor = nil
                UIPageControl.appearance().pageIndicatorTintColor = nil
            }
            .onChange(of: selection, perform: { newValue in
                
                guard let selectedSongIndex = songService.item.selectedSection, let selectedSong = songService.item.selectedSong else { return }
                guard selectedSongIndex + (songService.item.selectedSheetIndex ?? 0) != newValue else { return }
                if newValue >= selectedSongIndex + selectedSong.cluster.hasSheets.count {
                    songService.item.selectedSong = songService.item.songs[safe: selectedSongIndex + 1]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.selection = selectedSongIndex + 1
                    })
                } else if newValue < selectedSongIndex {
                    songService.item.selectedSong = songService.item.songs[safe: selectedSongIndex - 1]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.selection = selectedSongIndex - 1
                    })
                } else {
                    songService.item.selectedSheetId = songService.item.selectedSong?.sheets[safe: newValue - selectedSongIndex]?.id
                }
                
            })
            .onChange(of: songService.item.selectedSheetId) { _ in
                guard let index = songService.item.displayerSelectionIndex, selection != index else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.selection = index
                })
            }
            .onChange(of: songService.item.selectedSong) { _ in
                guard let selectedSongIndex = songService.item.selectedSection, selection != selectedSongIndex else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.selection = selectedSongIndex
                })
            }
        }
    }
    
    @ViewBuilder private func getTabView(screenSize: CGSize) -> some View {
        
        if songService.item.selectedSong == nil {
            EmptyView()
        } else {
            
            ForEach(Array(songService.item.songs.enumerated()), id: \.offset) { offset, songObject in
                
                if songService.item.selectedSong == nil {
                    
                    EmptyView()
                    
                } else if songObject.id == songService.item.selectedSong?.id {
                    
                    ForEach(Array(songObject.sheets.enumerated()), id: \.offset) { sheetOffset, sheet in
                        SheetUIHelper.sheet(viewSize: screenSize, ratioOnHeight: false, songServiceModel: songService, sheet: sheet, isForExternalDisplay: false, showSelectionCover: false)
                            .tag(songService.item.getSheetIndexWithSongIndexAddedIfNeeded(sheetOffset))
                    }
                    
                } else if let sheet = songObject.sheets.first {
                    
                    SheetUIHelper.sheet(viewSize: screenSize, ratioOnHeight: false, songServiceModel: songService, sheet: sheet, isForExternalDisplay: false, showSelectionCover: false)
                        .tag(songService.item.getSongIndexWithSheetIndexAddedIfNeeded(offset))
                    
                } else {
                    
                    EmptyView()
                    
                }
            }
            
        }
    }
}

struct BeamerViewUI2_Previews: PreviewProvider {
    @State static var songService = WrappedStruct(withItem: SongServiceUI(songs: []))
    
    static var previews: some View {
        let demoCluster = VCluster()
        let demoSheet = VSheetTitleContent()
        demoSheet.title = "Test title Leo"
        demoSheet.content = "Test content Leo"
        demoCluster.hasSheets = [demoSheet]
        return BeamerPreviewUI(songService: songService)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.landscapeLeft)
            .environmentObject(songService)
    }
}
