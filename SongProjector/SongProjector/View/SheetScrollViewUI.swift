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
    var songService: SongService
    @State var selectedSong: SongObject?
    let isSelectable: Bool
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if !songService.songs.isEmpty {
            GeometryReader { ruler in
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
                        ForEach(Array(selectedCluster.hasSheets.enumerated()), id: \.offset) { index, sheet in
                            TitleContentViewUI(position: index, scaleFactor: 1, sheet: sheet as! VSheetTitleContent, sheetTheme: VTheme())
                        }
                    }
                }
            } header: {
                SongServiceSectionViewUI(superViewSize: viewSize, song: songObject)
                    .sticky(frames, alignment: .horizontal)
                    .onTapGesture {
                        withAnimation(.easeOut) {
                            selectedSong = selectedSong?.cluster.id == songObject.cluster.id ? nil : songObject
                        }
                    }
            }
        }
    }
    
    @ViewBuilder func listViewItems(viewSize: CGSize) -> some View {
        if let selectedCluster = selectedSong?.cluster {
            VStack(spacing: 10) {
                let sheets = Array(selectedCluster.hasSheets.compactMap { $0 as? VSheetTitleContent }.enumerated())
                ForEach(sheets, id: \.offset) { index, sheet in
                    HStack() {
                        Text(sheet.title ?? "")
                            .lineLimit(2)
                            .font(.title)
                            .padding()
                            .padding([.leading], 30)
                        Spacer()
                    }.background(.white)
                        .cornerRadius(10)
                }
            }
        } else {
            EmptyView()
        }
    }
    
    private func isCompactOrVertical(viewSize: CGSize) -> Bool {
        viewSize.width < viewSize.height || horizontalSizeClass == .compact
    }

}

struct SheetScrollViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SheetScrollViewUI(songService: makeSongService(), isSelectable: true)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}
