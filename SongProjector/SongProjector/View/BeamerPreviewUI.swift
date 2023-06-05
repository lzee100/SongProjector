//
//  BeamerViewUI2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import UIKit

struct SendToExternalDisplayUseCase {
    
    private let connector: ExternalDisplayConnector
    
    init(connector: ExternalDisplayConnector) {
        self.connector = connector
    }
    
    func send(sheetViewModel: SheetViewModel?) {
        connector.sheetViewModel = sheetViewModel
    }

}

struct BeamerPreviewUI: View {
    
    let sendToExternalDisplayUseCase: SendToExternalDisplayUseCase
    @State private var selection: Int = -1
    @State private var previousSelection: Int = -1
    @State private var defaultTheme: ThemeCodable?
    @ObservedObject var songService: SongServiceUI
    private let displayerId = "DisplayerView"
    
    var body: some View {
        GeometryReader { screenProxy in
            if let defaultTheme {
                TabView(selection: $selection) {
                    getTabView(defaultTheme: defaultTheme)
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
                    
                    guard let selectedSongIndex = songService.selectedSection, let selectedSong = songService.selectedSong else { return }
                    guard selectedSongIndex + (songService.selectedSheetIndex ?? 0) != newValue else { return }
                    if newValue >= selectedSongIndex + selectedSong.cluster.hasSheets.count {
                        songService.selectedSong = songService.songs[safe: selectedSongIndex + 1]
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            self.selection = selectedSongIndex + 1
                        })
                    } else if newValue < selectedSongIndex {
                        songService.selectedSong = songService.songs[safe: selectedSongIndex - 1]
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            self.selection = selectedSongIndex - 1
                        })
                    } else {
                        songService.selectedSheetId = songService.selectedSong?.sheets[safe: newValue - selectedSongIndex]?.id
                    }
                    
                })
                .onChange(of: songService.selectedSheetId) { _ in
                    sendToExtenalDisplay()
                    guard let index = songService.displayerSelectionIndex, selection != index else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.selection = index
                    })
                }
                .onChange(of: songService.selectedSongSheetViewModels, perform: { newValue in
                    sendToExtenalDisplay()
                })
                .onChange(of: songService.selectedSong) { _ in
                    guard let selectedSongIndex = songService.selectedSection, selection != selectedSongIndex else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.selection = selectedSongIndex
                    })
                }
            }
        }
        .onAppear {
            Task {
                do {
                    let defaultTheme = try await CreateThemeUseCase().create()
                    await MainActor.run {
                        self.defaultTheme = defaultTheme
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func getTabView(defaultTheme: ThemeCodable) -> some View {
        
        if songService.selectedSong == nil {
            EmptyView()
        } else {
            
            ForEach(Array(songService.songs.enumerated()), id: \.offset) { offset, songObject in
                
                if songService.selectedSong == nil {
                    
                    EmptyView()
                    
                } else if songObject.id == songService.selectedSong?.id {
                    
                    ForEach(Array(songService.selectedSongSheetViewModels.enumerated()), id: \.offset) { sheetOffset, sheet in
                        SheetUIHelper.sheet(sheetViewModel: sheet, isForExternalDisplay: false)
                            .tag(songService.getSheetIndexWithSongIndexAddedIfNeeded(sheetOffset))
                    }
                    
                } else if let sheetModel = songService.songsFirstSheetModel[safe: offset] {
                    SheetUIHelper.sheet(sheetViewModel: sheetModel, isForExternalDisplay: false)
                        .tag(songService.getSongIndexWithSheetIndexAddedIfNeeded(songObject))
                    
                } else {
                    
                    EmptyView()
                    
                }
            }
            
        }
    }
    
    private func sendToExtenalDisplay() {
        let sheetId = songService.selectedSheetId
        if let sheetViewModel = songService.selectedSongSheetViewModels.first(where: { $0.id == sheetId }) {
            sendToExternalDisplayUseCase.send(sheetViewModel: sheetViewModel)
        } else {
            sendToExternalDisplayUseCase.send(sheetViewModel: nil)
        }
    }
    
    @ViewBuilder private func externalDisplaySheet(sheetModel: SheetViewModel) -> some View {
        SheetUIHelper.sheet(sheetViewModel: sheetModel, isForExternalDisplay: true)
    }
}

struct BeamerViewUI2_Previews: PreviewProvider {
    @State static var songService = SongServiceUI()
    
    static var previews: some View {
        let demoCluster = VCluster()
        let demoSheet = VSheetTitleContent()
        demoSheet.title = "Test title Leo"
        demoSheet.content = "Test content Leo"
        demoCluster.hasSheets = [demoSheet]
        return BeamerPreviewUI(sendToExternalDisplayUseCase: SendToExternalDisplayUseCase(connector: ExternalDisplayConnector()), songService: songService)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.landscapeLeft)
            .environmentObject(songService)
    }
}
