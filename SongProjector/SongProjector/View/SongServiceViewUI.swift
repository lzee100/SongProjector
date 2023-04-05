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
    
    @StateObject var songService: SongService
    @State private var alignment: Sticky.Alignment = .horizontal
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { ruler in
            VStack(alignment: .center, spacing: 0) {
                //                BeamerViewUI2(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet)
                //                    .padding(EdgeInsets(top: 10, leading: 50, bottom: 50, trailing: 50))
                //                    .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
                //                    .background(.black)
                BeamerPreviewUI(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet)
                    .padding(EdgeInsets(top: 10, leading: 50, bottom: 50, trailing: 50))
                    .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
                SheetScrollViewUI(
                    selectedSong: $songService.selectedSong,
                    selectedSheet: $songService.selectedSheet,
                    isSelectable: true
                )
                .frame(maxWidth: isCompactOrVertical(ruler: ruler) ? (ruler.size.width * 0.7) : .infinity, maxHeight: isCompactOrVertical(ruler: ruler) ? .infinity : 200)
            }
            .background(.black)
            .edgesIgnoringSafeArea(.all)
            .environmentObject(songService)
        }
    }
    
    func isCompactOrVertical(ruler: GeometryProxy) -> Bool {
        ruler.size.width < ruler.size.height || horizontalSizeClass == .compact
    }
}

struct SongServiceUI_Previews: PreviewProvider {
    @State static var songService = makeSongService()
    static var previews: some View {
        SongServiceViewUI(songService: songService)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewInterfaceOrientation(.portrait)
    }
}

func makeCluster() -> VCluster {
    let demoCluster = VCluster()
    let demoSheet = VSheetTitleContent()
    demoSheet.title = "Test title Leo"
    demoSheet.content = "Test content Leo"
    
    var demoSheets = [VSheetTitleContent]()
    for _ in 0..<10 {
        let demoSheet = VSheetTitleContent()
        demoSheet.title = "Test title Leo"
        demoSheet.content = "Test content Leo"
        demoSheets.append(demoSheet)
    }
    demoCluster.hasSheets = demoSheets
    return demoCluster
}

func makeSongService(_ hasSelectedSheet: Bool = false) -> SongService {
    let songService = SongService(delegate: nil)
    
    let selectedCluster = VCluster()
    selectedCluster.title = "Test Title 1"
    
    var sheets: [VSheetTitleContent] = []
    
    for index in 0..<2 {
        let sheet = VSheetTitleContent()
        sheet.title = "sheet \(index)"
        sheet.content = "sheet content \(index)"
        sheets.append(sheet)
    }
    
    selectedCluster.hasSheets = sheets
    let pianoSolo = VInstrument()
    pianoSolo.typeString = "pianoSolo"
    pianoSolo.resourcePath = "asd"
    selectedCluster.hasInstruments = [pianoSolo]
    
    let anotherCluster = VCluster()
    anotherCluster.title = "Test Title 2"
    let demoSheet2 = VSheetTitleContent()
    demoSheet2.title = "Test title Leo"
    demoSheet2.content = "Test content Leo"
    anotherCluster.hasSheets = [demoSheet2]
    anotherCluster.hasInstruments = makeDemoInstruments()
    
    let anotherCluster3 = VCluster()
    anotherCluster3.title = "Test Title 3"
    sheets = []
    for index in 0..<5 {
        let sheet = VSheetTitleContent()
        sheet.title = "sheet \(index)"
        sheet.content = "sheet content \(index)"
        sheet.hasTheme = VTheme()
        sheet.hasTheme?.isHidden = true
        sheets.append(sheet)
    }
    anotherCluster3.hasSheets = sheets
    
    songService.songs = [selectedCluster, anotherCluster, anotherCluster3].map { SongObject(cluster: $0, headerTitle: "") }
    if hasSelectedSheet {
        songService.selectedSong = songService.songs.last
    }
    return songService
}
