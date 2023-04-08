//
//  BeamerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct BeamerViewUI: View {
    @State var songsService: SongService
    var body: some View {
        BeamerPreviewUI(selectedSong: $songsService.selectedSong, selectedSheet: $songsService.selectedSheet)
            .environmentObject(songsService)
    }
}

struct BeamerViewUI_Previews: PreviewProvider {
    static var previews: some View {
        BeamerViewUI(songsService: makeSongService())
    }
}
