//
//  PianoSoloViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct PianoSoloViewUI: View {
    
    @Binding var selectedSong: SongObjectUI?
    @State var isAnimating = false
    @State var song: SongObjectUI
    @EnvironmentObject private var soundPlayer: SoundPlayer2
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    private var isPlayingPianoSolo: Bool {
        soundPlayer.selectedSong?.id == song.id && soundPlayer.isPlayingPianoSolo
    }
    
    var body: some View {
        GeometryReader { ruler in
            Button {
                withAnimation {
                    if isPlayingPianoSolo {
                        soundPlayer.stop()
                    } else {
                        selectedSong = nil
                        soundPlayer.play(song: song, pianoSolo: true)
                    }
                }
            } label: {
                if ruler.size.width < ruler.size.height || horizontalSizeClass == .compact {
                    contentPortrait
                } else {
                    contentLandscape
                }
            }
        }
        .background(Color(uiColor: .white))
        .cornerRadius(10)
    }
    
    @ViewBuilder private var contentPortrait: some View {
        VStack(alignment: .center) {
            Spacer(minLength: 0)
            if isPlayingPianoSolo {
                HStack {
                    Spacer()
                    playAnimation
                    Spacer()
                }
            } else {
                HStack {
                    Spacer()
                    pianoSoloImage
                        .padding(EdgeInsets(
                            top: 0,
                            leading: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40,
                            bottom: 0,
                            trailing: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40
                        ))
                    Spacer()
                }
            }
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder private var contentLandscape: some View {
        HStack(alignment: .center) {
            Spacer()
            if isPlayingPianoSolo {
                VStack {
                    Spacer()
                    playAnimation
                    Spacer()
                }
            } else {
                pianoSoloImage
            }
            Spacer()
        }
    }
    
    @ViewBuilder private var pianoSoloImage: some View {
        Image("Piano")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color(uiColor: .softBlueGrey))
    }
    
    @ViewBuilder private var playAnimation: some View {
        SoundAnimationViewUI(animationColor: Color(uiColor: .softBlueGrey))
    }
}

struct PianoSoloViewUI_Previews: PreviewProvider {
    
    @State static var selectedSong: SongObjectUI? = nil
    
    static var previews: some View {
        PianoSoloViewUI(selectedSong: $selectedSong, song: SongObjectUI(cluster: .makeDefault()!))
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}
