//
//  InstrumentsButtonsView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/09/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import UIKit

class InstrumentsButtonsView: UIStackView {
    
    init(instruments: [VInstrument]) {
        super.init(frame: .zero)
        instruments.forEach { addArrangedSubview(InstrumentView(instrument: $0)) }
        axis = .horizontal
        spacing = 2
        distribution = .fillEqually
    }
    
    func apply(instruments: [VInstrument]) {
        subviews.forEach { removeArrangedSubview($0) }
        subviews.forEach { $0.removeFromSuperview() }
        instruments.forEach { addArrangedSubview(InstrumentView(instrument: $0)) }
        axis = .horizontal
        spacing = 2
        distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
