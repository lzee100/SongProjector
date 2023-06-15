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
    
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    var superViewSize: CGSize
    @Binding var selectedSong: SongObjectUI?
    var song: SongObjectUI
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Group {
            if orientation.isPortrait {
                contentPortrait
            } else {
                contentLandscape
            }
        }
        .onRotate { orientation in
            self.orientation = orientation
        }
    }
    
    @ViewBuilder var contentPortrait: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                titleView
                Spacer()
            }
            Spacer()
            if song.cluster.hasPianoSolo {
                PianoSoloViewUI(selectedSong: $selectedSong, song: song)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200, minHeight: 40, maxHeight: 100)
                    .padding()
            } else {
                if song.cluster.hasLocalMusic {
                    instrumentsView
                } else {
                    EmptyView()
                }
            }
        }
        .background(Color(uiColor: .softBlueGrey))
        .cornerRadius(10)
    }
    
    @ViewBuilder var contentLandscape: some View {
        GeometryReader { ruler in
            VStack(spacing: 0) {
                ZStack {
                    
                    VStack {
                        Spacer()
                    titleView
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                        if song.cluster.hasPianoSolo {
                            PianoSoloViewUI(selectedSong: $selectedSong, song: song)
                                .frame(height: ruler.size.height * 0.25)
                        } else if song.cluster.hasLocalMusic {
                            instrumentsView
                        } else {
                            EmptyView()
                        }
                    }
                    
                }
            }
        }
        .background(Color(uiColor: .softBlueGrey))
        .aspectRatio(1.0, contentMode: .fit)
        .cornerRadius(10)
    }
    
    @ViewBuilder var titleView: some View {
        Text(song.cluster.title ?? "")
            .font(UIDevice.current.userInterfaceIdiom == .phone ? .normal : .xxNormal)
            .foregroundColor(.white)
            .lineLimit(2)
            .padding()
    }
    
    @ViewBuilder var instrumentsView: some View {
        InstrumentsViewUI(instruments: song.cluster.hasInstruments)
            .padding(orientation.isPortrait ? .all : .top)
    }
    
    private func isCompactOrVertical(viewSize: CGSize) -> Bool {
        viewSize.width < viewSize.height || horizontalSizeClass == .compact
    }
}

struct SongServiceSectionViewUI_Previews: PreviewProvider {
    @State static var selectedSong: SongObjectUI? = nil
    static var previews: some View {
        SongServiceSectionViewUI(superViewSize: superViewSizePortrait, selectedSong: $selectedSong, song: SongObjectUI(cluster: .makeDefault()!))
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
