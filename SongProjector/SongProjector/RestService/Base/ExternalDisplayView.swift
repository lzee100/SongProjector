//
//  ExternalDisplayView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

final class ExternalDisplayConnector: ObservableObject {
    @Published var toExternalDisplayView: AnyView?
    
    init(_ toExternalDisplayView: AnyView? = nil) {
        self.toExternalDisplayView = toExternalDisplayView
    }
}

struct ExternalDisplayView: View {
    
    @ObservedObject var externalDisplayConnector: ExternalDisplayConnector

    var body: some View {
        if let view = externalDisplayConnector.toExternalDisplayView {
            Text("yeah")
                .styleAs(font: .largeTitle, color: .white)
        } else {
            EmptyView()
        }
    }
}

struct ExternalDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalDisplayView(externalDisplayConnector: ExternalDisplayConnector())
    }
}
