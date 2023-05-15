//
//  InstrumentsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 20/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct InstrumentsViewUI: View {
    var instruments: [InstrumentCodable] = []
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(instruments) { instrument in
                InstrumentViewUI(instrument: instrument)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
    
}

struct InstrumentsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentsViewUI(instruments: [InstrumentCodable.makeDefault()!])
    }
}
