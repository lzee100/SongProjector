//
//  BeamerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct BeamerViewUI: View {
    @ObservedObject var songsService: SongServiceUI
    let sendToExternalDisplayUseCase: SendToExternalDisplayUseCase
    
    init(songsService: SongServiceUI, sendToExternalDisplayUseCase: SendToExternalDisplayUseCase) {
        self.songsService = songsService
        self.sendToExternalDisplayUseCase = sendToExternalDisplayUseCase
    }
    
    var body: some View {
        BeamerPreviewUI(sendToExternalDisplayUseCase: sendToExternalDisplayUseCase, songService: self.songsService)
    }
}

struct BeamerViewUI_Previews: PreviewProvider {
    @State static var songService = SongServiceUI()

    static var previews: some View {
        BeamerViewUI(songsService: songService, sendToExternalDisplayUseCase: SendToExternalDisplayUseCase(connector: ExternalDisplayConnector()))
    }
}
