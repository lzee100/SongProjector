//
//  SoundAnimationViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import Foundation

struct SoundAnimationViewUI: View {
    
    @EnvironmentObject private var soundPlayer: SoundPlayer2
    var animationColor: Color = .white
    @State private var update = false
    
    var body: some View {
        GeometryReader { ruler in
            Rectangle()
                .mask {
                    HStack(spacing: 4) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(.black)
                                .cornerRadius((((ruler.size.width * 0.4) - 20) / 6) / 2)
                                .frame(height: ruler.size.height * Double.random(in: 0.3..<0.8))
                                .scaleEffect(y: update ? Double.random(in: 0.1..<0.5) : 1.0)
                                .animation(.linear.repeatForever(autoreverses: true).delay(Double.random(in: 0.1..<0.5)), value: update)
                        }
                    }
//                    .frame(width: ruler.size.width * 0.2)
                }
                .tint(animationColor)
        }
        .onAppear {
            update.toggle()
            withAnimation(Animation.default.delay(0.5)) {
                update.toggle()
            }
        }
        .onChange(of: update) { value in
            print(value)
        }

    }
}

struct SoundAnimationViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SoundAnimationViewUI()
    }
}
