//
//  InstrumentsButtonsView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/09/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import UIKit

class InstrumentsButtonsView: UIStackView {
    
    let instrumentViews: [InstrumentView]
    
    init(instruments: [VInstrument]) {
        instrumentViews = instruments.map { InstrumentView(instrument: $0) }
        super.init(frame: .zero)
        instrumentViews.forEach({ addArrangedSubview($0) })
        axis = .horizontal
        spacing = 2
        distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
