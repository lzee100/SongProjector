//
//  MixerView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 03-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import VerticalSlider
import MediaPlayer

class MixerView: UIView {
    
    @IBOutlet var mixerView: UIView!
    @IBOutlet var pianoControl: VerticalSlider!
    @IBOutlet var guitarControl: VerticalSlider!
    @IBOutlet var bassGuitarControl: VerticalSlider!
    @IBOutlet var drumsControl: VerticalSlider!
    
    @IBOutlet var pianoImageView: UIImageView!
    @IBOutlet var guitarImageView: UIImageView!
    @IBOutlet var bassGuitarImageView: UIImageView!
    @IBOutlet var drumsImageView: UIImageView!
    @IBOutlet var airplaySliderContainer: UIView!
    
    var volumeViewCenterConstraint: NSLayoutConstraint?
    var volumeViewWidthConstraint: NSLayoutConstraint?
    var volumeViewHeightContraint: NSLayoutConstraint?
    
    private var progressObserver: NSKeyValueObservation!
    private let session = AVAudioSession.sharedInstance()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("MixerView", owner: self, options: [:])
        mixerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        addSubview(mixerView)
        self.setup()
    }
    
    func setup() {
        try? AVAudioSession.sharedInstance().setActive(true)
        let volumeView = MPVolumeView(frame: airplaySliderContainer.bounds)
        airplaySliderContainer.addSubview(volumeView)
        
        let color: UIColor = UIDevice.current.userInterfaceIdiom == .pad ? .white : .black
        pianoImageView.tintColor = color
        guitarImageView.tintColor = color
        bassGuitarImageView.tintColor = color
        drumsImageView.tintColor = color
        
        pianoControl.value = VolumeManager.getVolumeFor(instrumentType: .piano) ?? 0.5
        guitarControl.value = VolumeManager.getVolumeFor(instrumentType: .guitar) ?? 0.5
        bassGuitarControl.value = VolumeManager.getVolumeFor(instrumentType: .bassGuitar) ?? 0.5
        drumsControl.value = VolumeManager.getVolumeFor(instrumentType: .drums) ?? 0.5
        
        pianoControl.tintColor = .softBlueGreyBright
        guitarControl.tintColor = .softBlueGreyBright
        bassGuitarControl.tintColor = .softBlueGreyBright
        drumsControl.tintColor = .softBlueGreyBright
        
        pianoControl.addTarget(self, action: #selector(pianoSliderChanged), for: .valueChanged)
        guitarControl.addTarget(self, action: #selector(guitarSliderChanged), for: .valueChanged)
        bassGuitarControl.addTarget(self, action: #selector(bassGuitarSliderChanged), for: .valueChanged)
        drumsControl.addTarget(self, action: #selector(drumsSliderChanged), for: .valueChanged)
        
        updateVolumeSliders()
        
        progressObserver = AVAudioSession.sharedInstance().observe(\.outputVolume) { [weak self] (session, value) in
            self?.updateVolumeSliders()
        }
        
        NotificationCenter.default.addObserver(forName: .soundPlayerPlayedOrStopped, object: nil, queue: .main) { [weak self] not in
            self?.updateVolumeSliders()
        }
        
    }
    
    @objc func pianoSliderChanged() {
        set(volume: pianoControl.value, forType: .piano)
    }
    
    @objc func guitarSliderChanged() {
        set(volume: guitarControl.value, forType: .guitar)
    }
    
    @objc func bassGuitarSliderChanged() {
        set(volume: bassGuitarControl.value, forType: .bassGuitar)
    }
    
    @objc func drumsSliderChanged() {
        set(volume: drumsControl.value, forType: .drums)
    }
    
    private func set(volume: Float, forType: InstrumentType) {
        SoundPlayer.playerFor(instrumentType: forType)?.setVolume(volume, fadeDuration: 0)
        VolumeManager.set(volume: volume, instrumentType: forType)
    }
    
    private func updateVolumeSliders() {
        
        if let savedVolume = VolumeManager.getVolumeFor(instrumentType: .piano) {
            if SoundPlayer.playerFor(instrumentType: .piano)?.volume ?? 0 == 0 {
                pianoControl.slider.value = savedVolume
            } else {
                pianoControl.slider.value = savedVolume * AVAudioSession.sharedInstance().outputVolume
            }
        } else {
            pianoControl.slider.value = AVAudioSession.sharedInstance().outputVolume
        }
        
        if let savedVolume = VolumeManager.getVolumeFor(instrumentType: .guitar) {
            if SoundPlayer.playerFor(instrumentType: .guitar)?.volume ?? 0 == 0 {
                guitarControl.slider.value = savedVolume
            } else {
                guitarControl.slider.value = savedVolume * AVAudioSession.sharedInstance().outputVolume
            }
        } else {
            guitarControl.slider.value = AVAudioSession.sharedInstance().outputVolume
        }
        
        if let savedVolume = VolumeManager.getVolumeFor(instrumentType: .bassGuitar) {
            if SoundPlayer.playerFor(instrumentType: .bassGuitar)?.volume ?? 0 == 0 {
                bassGuitarControl.slider.value = savedVolume
            } else {
                bassGuitarControl.slider.value = savedVolume * AVAudioSession.sharedInstance().outputVolume
            }
        } else {
            bassGuitarControl.slider.value = AVAudioSession.sharedInstance().outputVolume
        }
        
        if let savedVolume = VolumeManager.getVolumeFor(instrumentType: .drums) {
            if SoundPlayer.playerFor(instrumentType: .drums)?.volume ?? 0 == 0 {
                drumsControl.slider.value = savedVolume
            } else {
                drumsControl.slider.value = savedVolume * AVAudioSession.sharedInstance().outputVolume
            }
        } else {
            drumsControl.slider.value = AVAudioSession.sharedInstance().outputVolume
        }
        
    }
    
}

struct VolumeManager {
    
    private static let instrument = "instrument"
    
    static func set(volume: Float, instrumentType: InstrumentType) {
        UserDefaults.standard.setValue("1", forKey: instrumentType.rawValue + instrument)
        UserDefaults.standard.setValue(volume, forKey: instrumentType.rawValue)
    }
    
    static func getVolumeFor(instrumentType: InstrumentType) -> Float? {
        guard UserDefaults.standard.string(forKey: instrumentType.rawValue + instrument) != nil else { return nil }
        return UserDefaults.standard.float(forKey: instrumentType.rawValue)
    }
    
}
