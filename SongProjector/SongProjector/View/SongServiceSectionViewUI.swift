//
//  SongServiceHeaderViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 20/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import UIKit

struct SongServiceSectionViewUI: View {
    
    var superViewSize: CGSize
    @Binding var selectedSong: SongObject?
    var song: SongObject
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        Group {
            if isCompactOrVertical(viewSize: superViewSize) {
                contentPortrait
            } else {
                contentLandscape
            }
        }
        .background(Color(uiColor: .softBlueGrey))
        .aspectRatio(1.0, contentMode: .fit)
        .cornerRadius(10)
    }
    
    @ViewBuilder var contentPortrait: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                titleView
                Spacer()
            }
            Spacer()
            if song.cluster.hasPianoSolo {
                PianoSoloViewUI(selectedSong: $selectedSong)
                    .padding()
                    .frame(maxWidth: 200, minHeight: 0, maxHeight: 100)
            } else {
                instrumentsView
            }
        }
    }
    
    @ViewBuilder var contentLandscape: some View {
        GeometryReader { ruler in
            VStack(spacing: 0) {
                Spacer()
                titleView
                Spacer()
                if song.cluster.hasPianoSolo {
                    PianoSoloViewUI(selectedSong: $selectedSong)
                        .frame(height: isCompactOrVertical(viewSize: ruler.size) ? ruler.size.height * 0.9 : ruler.size.height * 0.25)
                } else {
                    instrumentsView
                }
            }
        }
    }
    
    @ViewBuilder var titleView: some View {
        Text(song.cluster.title ?? "")
            .font(.largeTitle)
            .foregroundColor(.white)
            .lineLimit(2)
            .padding()
    }
    
    @ViewBuilder var instrumentsView: some View {
        InstrumentsViewUI(instruments: makeDemoInstruments())
            .padding(isCompactOrVertical(viewSize: superViewSize) ? .all : .top)
    }
    
    private func isCompactOrVertical(viewSize: CGSize) -> Bool {
        viewSize.width < viewSize.height || horizontalSizeClass == .compact
    }
}

struct SongServiceSectionViewUI_Previews: PreviewProvider {
    @State static var selectedSong: SongObject? = nil
    static var previews: some View {
        SongServiceSectionViewUI(superViewSize: superViewSizePortrait, selectedSong: $selectedSong, song: makeSongService().songs.first!)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}

private var superViewSizeLandscape: CGSize {
    return CGSize(width: 300, height: 200)
}

private var superViewSizePortrait: CGSize {
    return CGSize(width: 200, height: 300)
}
