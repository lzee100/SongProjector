//
//  PianoSoloButtonView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

class PianoSoloButtonView: ActionButton {
    
    private let iconImageView = UIImageView(image: UIImage(named: "Piano"))
//    private let equalizerAnimationView = MixerAnimationView(frame: .zero, mixerColor: .white)
    private let soundAnimationView = MixerAnimationViewNew(frame: .zero)
    private let iconInsets: UIEdgeInsets
    private let equalizerInsets: UIEdgeInsets
    
    init(iconInsets: UIEdgeInsets, equalizerInsets: UIEdgeInsets, action: @escaping ActionButton.Action, isPianoSoloPlaying: Bool) {
        self.iconInsets = iconInsets
        self.equalizerInsets = equalizerInsets
        super.init(frame: .zero)
        add(action: action)
        setup()
        if isPianoSoloPlaying {
            startPlay()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startPlay() {
        soundAnimationView.startPlay()
        soundAnimationView.isHidden = false
//        equalizerAnimationView.play()
//        equalizerAnimationView.isHidden = false
        iconImageView.isHidden = true
    }
    
    func stopPlay() {
        soundAnimationView.stopPlay()
        soundAnimationView.isHidden = true
//        equalizerAnimationView.stop()
        iconImageView.isHidden = false
//        equalizerAnimationView.isHidden = true
    }
    
    func isColorInverted(_ isInverted: Bool) {
        backgroundColor = isInverted ? .whiteColor : .softBlueGrey
        iconImageView.tintColor = isInverted ? .softBlueGrey : .whiteColor
    }
    
    private func setup() {
        isColorInverted(false)
        [soundAnimationView, iconImageView].forEach { view in
            view.isHidden = true
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        iconImageView.isHidden = false
        setConstraintsIconImageView()
        setConstraintsEqualizerAnimationView()
    }
    
    private func setConstraintsIconImageView() {
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: iconInsets.top).isActive = true
        iconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: iconInsets.left).isActive = true
        iconImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -iconInsets.right).isActive = true
        iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -iconInsets.bottom).isActive = true
    }
    
    private func setConstraintsEqualizerAnimationView() {
//        equalizerAnimationView.widthAnchor.constraint(equalTo: equalizerAnimationView.heightAnchor).isActive = true
//        equalizerAnimationView.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        equalizerAnimationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        equalizerAnimationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        equalizerAnimationView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: equalizerInsets.top).isActive = true
//        equalizerAnimationView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: equalizerInsets.left).isActive = true
//        equalizerAnimationView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -equalizerInsets.right).isActive = true
//        equalizerAnimationView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -equalizerInsets.bottom).isActive = true

        soundAnimationView.widthAnchor.constraint(equalTo: soundAnimationView.heightAnchor).isActive = true
        soundAnimationView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        soundAnimationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        soundAnimationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        soundAnimationView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: equalizerInsets.top).isActive = true
        soundAnimationView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: equalizerInsets.left).isActive = true
        soundAnimationView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -equalizerInsets.right).isActive = true
        soundAnimationView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -equalizerInsets.bottom).isActive = true
    }
}
