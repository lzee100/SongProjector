//
//  CollectionListViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct CollectionListViewUI: View {

    let isSelectable: Bool
    let isSelected: Bool
    @StateObject var collection: WrappedStruct<ClusterCodable>
    @EnvironmentObject private var soundPlayer: SoundPlayer2
    @ObservedObject private var collectionsViewModel: CollectionsViewModel
    @EnvironmentObject private var musicDownloadManager: MusicDownloadManager

    init(
        collectionsViewModel: CollectionsViewModel,
        collection: ClusterCodable,
        isSelectable: Bool,
        isSelected: Bool
    ) {
        self._collection = StateObject(wrappedValue: WrappedStruct(withItem: collection))
        self.collectionsViewModel = collectionsViewModel
        self.isSelectable = isSelectable
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack {
            if isSelectable {
                Rectangle().fill(isSelected ? Color(uiColor: .softBlueGrey) : .clear)
                    .cornerRadius(5 / 2)
                    .frame(width: 5)
            }
            Text(collection.item.title ?? "-")
                .foregroundColor(Color(uiColor: isSelected ? .softBlueGrey : .blackColor.withAlphaComponent(0.8)))
                .styleAs(font: .xNormal)
            Spacer()
            if collection.item.hasInstruments.count > 0 && !collection.item.hasLocalMusic {
                MusicDownloadButtonViewUI(
                    collection: collection
                )
            } else if collection.item.hasLocalMusic {
                if collection.item.hasPianoSolo {
                    pianoSoloImageView
                }
                if soundPlayer.selectedSong?.id == collection.item.id {
                    soundAnimationView
                } else {
                    playLocalMusicButton
                }
            }
        }
        .onReceive(musicDownloadManager.objectWillChange) { _ in
            
        }
    }
    
    @ViewBuilder var pianoSoloImageView: some View {
            Image("Piano")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color(uiColor: .blackColor))
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
    }
    
    @ViewBuilder var playLocalMusicButton: some View {
        Button {
            soundPlayer.play(song: SongObjectUI(cluster: collection.item))
        } label: {
            Image("Play")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color(uiColor: .blackColor))
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder var soundAnimationView: some View {
        Button {
            soundPlayer.stop()
        } label: {
            SoundAnimationViewUI(animationColor: Color(uiColor: .softBlueGrey))
                .frame(width: 30, height: 30)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        }
        .buttonStyle(.plain)
    }
}

struct CollectionListViewUI_Previews: PreviewProvider {
    static var previews: some View {
        CollectionListViewUI(collectionsViewModel: CollectionsViewModel(), collection: .makeDefault()!, isSelectable: false, isSelected: false)
            .previewLayout(.sizeThatFits)
    }
}
