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
    @State var animationColor: Color = .white
    @State private var update = false
    private let size = CGSize(width: 40, height: 40)
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Rectangle()
            .frame(width: size.width, height: size.height)
            .mask {
                HStack(spacing: 4) {
                    ForEach(0..<6) { _ in
                        Rectangle()
                            .fill(.black)
                            .cornerRadius((((size.width * 0.4) - 20) / 6) / 2)
                            .frame(height: size.height * Double.random(in: 0.3..<0.8))
//                            .frame(height: size.height * 0.2)
                            .scaleEffect(y: update ? Double.random(in: 0.1..<0.5) : 1.0)
                            .animation(.linear.delay(Double.random(in: 0.1..<0.5)), value: update)
                    }
                }
                .onReceive(timer) { _ in
                    update.toggle()
                }

            }
            .tint(animationColor)
    }
}

struct SoundAnimationViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SoundAnimationViewUI()
    }
}
