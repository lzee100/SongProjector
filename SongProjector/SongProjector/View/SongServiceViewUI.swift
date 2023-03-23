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
    
    @State var songService: SongService
    @State private var alignment: Sticky.Alignment = .horizontal
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        GeometryReader { ruler in
            VStack(alignment: .center, spacing: 0) {
                BeamerViewUI2(selectedCluster: makeCluster())
                    .padding(EdgeInsets(top: 10, leading: 50, bottom: 50, trailing: 50))
                    .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
                    .background(.black)
                SheetScrollViewUI(songService: songService, isSelectable: true)
                    .frame(
                        width: isCompactOrVertical(ruler: ruler) ? (ruler.size.width * 0.7) : .infinity,
                        height: isCompactOrVertical(ruler: ruler) ? .infinity : 200
                    )
            }
            .background(.black)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func isCompactOrVertical(ruler: GeometryProxy) -> Bool {
        ruler.size.width < ruler.size.height || horizontalSizeClass == .compact
    }
}

struct SongServiceUI_Previews: PreviewProvider {
    
    static var previews: some View {
        SongServiceViewUI(songService: makeSongService())
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

func makeSongService() -> SongService {
    let songService = SongService(delegate: nil)
    
    let selectedCluster = VCluster()
    selectedCluster.title = "Test Title 1"
    let demoSheet = VSheetTitleContent()
    demoSheet.title = "Test title Leo"
    demoSheet.content = "Test content Leo"
    selectedCluster.hasSheets = [demoSheet]
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
    anotherCluster3.title = "Test Title 2"
    let demoSheet3 = VSheetTitleContent()
    demoSheet3.title = "Test title Leo"
    demoSheet3.content = "Test content Leo"
    anotherCluster3.hasSheets = [demoSheet3]
    anotherCluster3.hasInstruments = makeDemoInstruments()
    
    songService.songs = [selectedCluster, anotherCluster, anotherCluster3].map { SongObject(cluster: $0, headerTitle: "") }
    return songService
}
