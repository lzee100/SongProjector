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
    @State var isPlaying = false
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Group {
            GeometryReader { ruler in
                if ruler.size.width < ruler.size.height || horizontalSizeClass == .compact {
                    contentPortrait
                } else {
                    contentLandscape
                }
            }
        }
        .background(Color(uiColor: .white))
        .cornerRadius(10)
        .onTapGesture {
            isPlaying.toggle()
            isAnimating.toggle()
            if isPlaying, selectedSong != nil {
                withAnimation {
                    selectedSong = nil
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                isAnimating.toggle()
            })
        }
        
    }
    
    @ViewBuilder private var contentPortrait: some View {
        VStack(alignment: .center) {
            Spacer()
            if isPlaying {
                playAnimation
            } else {
                pianoSoloImage
                    .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
            }
            Spacer()
        }
    }
    
    @ViewBuilder private var contentLandscape: some View {
        HStack(alignment: .center) {
            Spacer()
            if isPlaying {
                playAnimation
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
        GeometryReader { ruler in
            SoundAnimationViewUI()
                .foregroundColor(Color(uiColor: .softBlueGrey))
                .padding(EdgeInsets(
                    top: 0,
                    leading: isCompactOrVertical(ruler: ruler) ? 80 : 0,
                    bottom: 0,
                    trailing: isCompactOrVertical(ruler: ruler) ? 80 : 0)
                )
        }
    }
    
    private func isCompactOrVertical(ruler: GeometryProxy) -> Bool {
        ruler.size.width < ruler.size.height || horizontalSizeClass == .compact
    }

}

struct PianoSoloViewUI_Previews: PreviewProvider {
    
    @State static var selectedSong: SongObjectUI? = nil
    
    static var previews: some View {
        PianoSoloViewUI(selectedSong: $selectedSong, isPlaying: false)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}
