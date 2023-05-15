//
//  CircleProgressViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct CircleProgressViewUI: View {
    
    @ObservedObject var fetchMusicUseCase: FetchMusicUseCase
    @State var color: Color = Color(uiColor: .green1)
    @State var lineWidth: CGFloat = 10
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .foregroundColor(color)
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 0.2), value: fetchMusicUseCase.progress.progress)
    }
}

struct CircleProgressViewUI_Previews: PreviewProvider {
    static var previews: some View {
        CircleProgressViewUI(fetchMusicUseCase: FetchMusicUseCase(cluster: .makeDefault()!))
    }
}
