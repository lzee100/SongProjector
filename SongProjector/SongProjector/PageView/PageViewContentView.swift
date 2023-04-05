//
//  PageViewContentView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct PageViewContentView: View {
    @EnvironmentObject var songService: SongService
    @Binding var selectedSong: SongObject?
    @Binding var selectedSheet: VSheet?

    var body: some View {
        
        GeometryReader { proxy in
            let size = proxy.size
            SheetDisplayerPageView(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet)
        }.ignoresSafeArea()
    }
}

struct PageViewContentView_Previews: PreviewProvider {
    
    @State private static var songService = makeSongService(true)
    static var previews: some View {
        PageViewContentView(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet)
            .environmentObject(songService)
    }
}
