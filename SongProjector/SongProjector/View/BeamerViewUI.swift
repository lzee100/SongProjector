//
//  BeamerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct BeamerViewUI: View {
    @State var songsService: WrappedStruct<SongServiceUI>
    
    init(songsService: WrappedStruct<SongServiceUI>) {
        self.songsService = songsService
    }
    
    var body: some View {
        BeamerPreviewUI(songService: self.songsService)
    }
}

struct BeamerViewUI_Previews: PreviewProvider {
    @State static var songService = WrappedStruct(withItem: SongServiceUI(songs: []))

    static var previews: some View {
        BeamerViewUI(songsService: songService)
    }
}
