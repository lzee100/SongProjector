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
    }
	
	func customInit() {
		Bundle.main.loadNibNamed("MixerView", owner: self, options: [:])
		mixerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		addSubview(mixerView)
		self.setup()
	}
	
	func setup() {
		let volumeView = MPVolumeView(frame: airplaySliderContainer.bounds)
		airplaySliderContainer.addSubview(volumeView)
	
        pianoImageView.tintColor = .blackColor
		guitarImageView.tintColor = .blackColor
		bassGuitarImageView.tintColor = .blackColor
		drumsImageView.tintColor = .blackColor
        
        pianoControl.tintColor = .softBlueGreyBright
        guitarControl.tintColor = .softBlueGreyBright
        bassGuitarControl.tintColor = .softBlueGreyBright
        drumsControl.tintColor = .softBlueGreyBright
        		
		pianoControl.addTarget(self, action: #selector(pianoSliderChanged), for: .valueChanged)
		guitarControl.addTarget(self, action: #selector(guitarSliderChanged), for: .valueChanged)
		bassGuitarControl.addTarget(self, action: #selector(bassGuitarSliderChanged), for: .valueChanged)
		drumsControl.addTarget(self, action: #selector(drumsSliderChanged), for: .valueChanged)
        
        updateVolumeSliders()
        
        NotificationCenter.default.addObserver(self, selector: #selector(volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)

		
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
        print(SoundPlayer.playerFor(instrumentType: .piano)?.volume ?? 1)
        pianoControl.slider.value = SoundPlayer.playerFor(instrumentType: .piano)?.volume ?? 1
        guitarControl.slider.value = SoundPlayer.playerFor(instrumentType: .guitar)?.volume ?? 1
        bassGuitarControl.slider.value = SoundPlayer.playerFor(instrumentType: .bassGuitar)?.volume ?? 1
        drumsControl.slider.value = SoundPlayer.playerFor(instrumentType: .drums)?.volume ?? 1
    }
    
    @objc private func volumeDidChange(notification: NSNotification) {
        SoundPlayer.updateVolumeBasedOnGlobalVolume()
        updateVolumeSliders()
    }
	

}

struct VolumeManager {
    
    
    static func set(volume: Float, instrumentType: InstrumentType) {
        UserDefaults.standard.setValue("1", forKey: instrumentType.rawValue)
        UserDefaults.standard.setValue(volume, forKey: instrumentType.rawValue)
    }
    
    static func getVolumeFor(instrumentType: InstrumentType) -> Float? {
        guard UserDefaults.standard.string(forKey: instrumentType.rawValue) != nil else { return nil }
        return UserDefaults.standard.float(forKey: instrumentType.rawValue)
    }
    
}
