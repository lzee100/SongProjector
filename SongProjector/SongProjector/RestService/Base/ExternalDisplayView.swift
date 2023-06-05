//
//  ExternalDisplayView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

final class ExternalDisplayConnector: ObservableObject {
    @Published var sheetViewModel: SheetViewModel?
    
    init(_ sheetViewModel: SheetViewModel? = nil) {
        self.sheetViewModel = sheetViewModel
    }
}

struct ExternalDisplayView: View {
    
    @ObservedObject var externalDisplayConnector: ExternalDisplayConnector

    var body: some View {
        if let sheetViewModel = externalDisplayConnector.sheetViewModel {
            SheetUIHelper.sheet(sheetViewModel: sheetViewModel, isForExternalDisplay: true)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea(.all)
        } else {
            Rectangle().fill(.black)
        }
    }
}

struct ExternalDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalDisplayView(externalDisplayConnector: ExternalDisplayConnector())
    }
}
