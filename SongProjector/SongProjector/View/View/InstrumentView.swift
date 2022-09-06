//
//  InstrumentView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/09/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class InstrumentView: ActionButton {
    
    private let instrumentIV = UIImageView()
    private let backgroundView = UIView()
    private let selectionView = UIView()
    private let containerView = UIView()
    private unowned let instrument: VInstrument
    
    init(instrument: VInstrument) {
        self.instrument = instrument
        super.init(frame: .zero)
        
        self.instrumentIV.image = instrument.image?.withRenderingMode(.alwaysTemplate)
        instrumentIV.tintColor = UIColor.blackColor
        backgroundView.backgroundColor = UIColor.whiteColor
        selectionView.backgroundColor = .orange
        
        addSubview(containerView)
        containerView.addSubview(backgroundView)
        containerView.addSubview(selectionView)
        containerView.addSubview(instrumentIV)
        
        clipsToBounds = true
        [containerView, instrumentIV, backgroundView, selectionView].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
        })
        instrumentIV.anchorToSuperView(insets: .init(cgFloat: 10))
        backgroundView.anchorToSuperView(insets: .init(cgFloat: 2))

        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        selectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        selectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        selectionView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        selectionView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        updateInstrumentView()
        
        add {
            let newValue = !VolumeManager.isMutedFor(instrument: instrument)
            VolumeManager.setMuteFor(instrument: instrument, isMuted: newValue)
            if let type = instrument.type {
                SoundPlayer.setVolumeFor(type, volume: newValue ? 0 : (VolumeManager.getVolumeFor(instrumentType: type) ?? 0.5), saveValue: false)
            }
            self.updateInstrumentView()
        }
        
        NotificationCenter.default.addObserver(forName: .didResetInstrumentMutes, object: nil, queue: .main) { [weak self] _ in
            self?.updateInstrumentView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInstrumentView() {
        selectionView.isHidden = VolumeManager.isMutedFor(instrument: instrument)
    }
    
}
