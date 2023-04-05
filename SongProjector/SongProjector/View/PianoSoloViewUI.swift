//
//  PianoSoloViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct PianoSoloViewUI: View {
    
    @Binding var selectedSong: SongObject?
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
            
            Rectangle()
                    .mask {
                        HStack(spacing: 4) {
                            ForEach(0..<6) { _ in
                                Rectangle()
                                    .cornerRadius((((ruler.size.width * 0.4) - 20) / 6) / 2)
                                    .frame(height: ruler.size.height * Double.random(in: 0.3..<0.8))
                                    .scaleEffect(y: isAnimating ? Double.random(in: 0.1..<0.5) : 1.0)
                                    .animation(.linear.repeatForever(autoreverses: true).delay(Double.random(in: 0.1..<0.5)), value: isAnimating)
                            }
                        }
                        .frame(width: ruler.size.width * 0.2)
                    }
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
    
    @State static var selectedSong: SongObject? = nil
    
    static var previews: some View {
        PianoSoloViewUI(selectedSong: $selectedSong, isPlaying: false)
            .previewLayout(.sizeThatFits)
            .previewInterfaceOrientation(.portrait)
    }
}
