//
//  SwiftUITestView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct SwiftUITestView: View {
    var body: some View {
        VStack {
            Rectangle().fill(.orange).aspectRatio(1.0, contentMode: .fit).overlay {
                Text("Hello, World!")
                    .background(.blue)
                    .aspectRatio(1, contentMode: .fill)
            }
            Spacer()
        }
    }
}

struct SwiftUITestView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUITestView()
    }
}
