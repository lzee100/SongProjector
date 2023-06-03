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
    private unowned let instrument: VInstrument
    
    init(instrument: VInstrument) {
        self.instrument = instrument
        super.init(frame: .zero)
        
        self.instrumentIV.image = instrument.image?.withRenderingMode(.alwaysTemplate)
        instrumentIV.tintColor = UIColor.blackColor
        backgroundView.backgroundColor = UIColor.whiteColor
        selectionView.backgroundColor = .orange
        
        addSubview(backgroundView)
        addSubview(selectionView)
        addSubview(instrumentIV)
        
        clipsToBounds = true
        [instrumentIV, backgroundView, selectionView].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
        })
        backgroundView.anchorToSuperView(insets: .init(cgFloat: 2))
        
        selectionView.constraints.forEach { selectionView.removeConstraint($0) }
        selectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        selectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        selectionView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        selectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if UIDeviceOrientation.isPortrait {
            updateConstraintsForPortrait()
        } else {
            updateConstraintsForLandschape()
        }
        
        updateInstrumentView()
        
        add { [weak self] in
            guard let self = self else { return }
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
    
    func updateConstraintsForLandschape() {
        instrumentIV.constraints.forEach { instrumentIV.removeConstraint($0) }
        instrumentIV.widthAnchor.constraint(equalTo: instrumentIV.heightAnchor).isActive = true
        instrumentIV.anchorToSuperView(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    func updateConstraintsForPortrait() {
        instrumentIV.constraints.forEach { instrumentIV.removeConstraint($0) }
        instrumentIV.anchorToSuperView(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        instrumentIV.widthAnchor.constraint(equalTo: instrumentIV.heightAnchor).isActive = true
        instrumentIV.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
}


import Foundation
import UIKit
import AudioToolbox

class DemoInstrumentView: ActionButton {
    
    private let instrumentIV = UIImageView()
    private let backgroundView = UIView()
    private let selectionView = UIView()
    
    init() {
        super.init(frame: .zero)
        
        self.instrumentIV.image = UIImage(named: "BassGuitar")?.withRenderingMode(.alwaysTemplate)
        instrumentIV.tintColor = UIColor.blackColor
        backgroundView.backgroundColor = UIColor.whiteColor
        selectionView.backgroundColor = .orange
        
        addSubview(backgroundView)
        addSubview(selectionView)
        addSubview(instrumentIV)
        
        clipsToBounds = true
        [instrumentIV, backgroundView, selectionView].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
        })
        backgroundView.anchorToSuperView(insets: .init(cgFloat: 2))
        
        selectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        selectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        selectionView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        selectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        instrumentIV.anchorToSuperView(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        instrumentIV.widthAnchor.constraint(equalTo: instrumentIV.heightAnchor).isActive = true
        instrumentIV.widthAnchor.constraint(equalToConstant: 30).isActive = true

        updateInstrumentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInstrumentView() {
//        selectionView.isHidden = VolumeManager.isMutedFor(instrument: instrument)
    }
    
}

