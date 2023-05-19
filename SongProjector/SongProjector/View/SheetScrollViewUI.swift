//
//  SheetScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct SheetScrollViewUI: View {
    
    @State private var orientation: UIDeviceOrientation = .unknown
    @State private var frames: [CGRect] = []
    @ObservedObject private(set) var songServiceModel: WrappedStruct<SongServiceUI>
    @State private var nextSelectedSong: SongObjectUI? = nil
    var superViewSize: CGSize
    
    let isSelectable: Bool
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if !songServiceModel.item.songs.isEmpty {
            GeometryReader { ruler in
                
                ScrollViewReader { value in
                    ScrollView(isCompactOrVertical(viewSize: superViewSize) ? .vertical : .horizontal) {
                        if isCompactOrVertical(viewSize: superViewSize) {
                            VStack(spacing: 10) {
                                scrollViewItemsPortrait(viewSize: superViewSize)
                            }
                        } else {
                            HStack(spacing: 10) {
                                scrollViewItemsLandscape()
                            }
                        }
                    }
                    .coordinateSpace(name: "container")
                    .onPreferenceChange(FramePreference.self, perform: {
                        frames = $0
                    })
                    .onChange(of: songServiceModel.item.selectedSheetId) { newValue in
                        guard let selectedSheetId = songServiceModel.item.selectedSheetId else { return }
                        
                        withAnimation {
                            value.scrollTo(selectedSheetId, anchor: .center)
                        }
                    }
                    .onRotate { orientation in
                        self.orientation = orientation
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder func scrollViewItemsLandscape() -> some View {
        ForEach(Array(songServiceModel.item.sectionedSongs.enumerated()), id: \.offset) { offset, songObjectsPerSection in
            VStack {
                Text(songObjectsPerSection.title)
                    .styleAs(font: .xNormalBold, color: .white)
                HStack(spacing: 10) {
                    ForEach(Array(songObjectsPerSection.songs.enumerated()), id: \.offset) { index, songObject in
                        Section {
                            if let selectedSong = songServiceModel.item.selectedSong,  songObject.cluster.id == selectedSong.id {
                                HStack {
                                    ForEach(Array(selectedSong.sheets.enumerated()), id: \.offset) { sheetIndex, sheet in
                                        SheetUIHelper.sheet(ratioOnHeight: true, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: false, showSelectionCover: true)
                                            .id(sheet.id)
                                    }
                                }
                            }
                        } header: {
                            SongServiceSectionViewUI(superViewSize: superViewSize, selectedSong: $songServiceModel.item.selectedSong, song: songObject)
                                .sticky(frames, alignment: .horizontal)
                                .onTapGesture {
                                    songServiceModel.item.selectedSong = songServiceModel.item.selectedSong?.id == songObject.id ? nil : songObject
                                }
                                .id(songObject.id)
                        }
                    }
                }
            }
            .styleAsSectionBackground(edgeInsets: EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
        }
    }
    
    @ViewBuilder func scrollViewItemsPortrait(viewSize: CGSize) -> some View {
        ForEach(Array(songServiceModel.item.sectionedSongs.enumerated()), id: \.offset) { offset, songObjectsPerSection in
            VStack(spacing: 10) {
                Text(songObjectsPerSection.title)
                    .styleAs(font: .xNormalBold, color: .white)
                ForEach(Array(songObjectsPerSection.songs.enumerated()), id: \.offset) { index, songObject in
                    VStack(spacing: 10) {
                        sectionedItemsFor(viewSize: viewSize, index: index, songObject: songObject)
                    }
                }
            }
            .styleAsSectionBackground()
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
//        viewSize.width < viewSize.height || horizontalSizeClass == .compact
        print(viewSize.width < viewSize.height || horizontalSizeClass == .compact ? "portrait" : "landscape")
        return viewSize.width < viewSize.height || horizontalSizeClass == .compact
    }

}

struct SheetScrollViewUI_Previews: PreviewProvider {
    @State static var songService = WrappedStruct(withItem: SongServiceUI(songs: []))

    static var previews: some View {
        SheetScrollViewUI(songServiceModel: songService, superViewSize: .zero, isSelectable: true)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}

struct SectionBackgroundModifier: ViewModifier {
    
    var color: Color = .white
    var edgeInsets: EdgeInsets
    
    func body(content: Content) -> some View {
        content
            .padding(edgeInsets)
            .background(color.opacity(0.2))
            .cornerRadius(10)
    }
    
}
extension View {
    func styleAsSectionBackground(color: Color = .white, edgeInsets: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 25, trailing: 10)) -> some View {
        modifier(SectionBackgroundModifier(color: color, edgeInsets: edgeInsets))
    }
}
