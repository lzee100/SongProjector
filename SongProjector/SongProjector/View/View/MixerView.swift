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
	
	func customInit() {
		Bundle.main.loadNibNamed("MixerView", owner: self, options: [:])
		mixerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		addSubview(mixerView)
		self.setup()
	}
	
	func setup() {
		let volumeView = MPVolumeView(frame: airplaySliderContainer.bounds)
		airplaySliderContainer.addSubview(volumeView)
	
		pianoImageView.tintColor = themeHighlighted
		guitarImageView.tintColor = themeHighlighted
		bassGuitarImageView.tintColor = themeHighlighted
		drumsImageView.tintColor = themeHighlighted
		
		pianoControl.value = 1
		guitarControl.value = 1
		bassGuitarControl.value = 1
		drumsControl.value = 1
		
		pianoControl.addTarget(self, action: #selector(pianoSliderChanged), for: .valueChanged)
		guitarControl.addTarget(self, action: #selector(guitarSliderChanged), for: .valueChanged)
		bassGuitarControl.addTarget(self, action: #selector(bassGuitarSliderChanged), for: .valueChanged)
		drumsControl.addTarget(self, action: #selector(drumsSliderChanged), for: .valueChanged)
		
	}
	
	@objc func pianoSliderChanged() {
		SoundPlayer.playerFor(instrumentType: .piano)?.setVolume(pianoControl.value, fadeDuration: 0)
	}
	
	@objc func guitarSliderChanged() {
		SoundPlayer.playerFor(instrumentType: .guitar)?.setVolume(guitarControl.value, fadeDuration: 0)
	}
	
	@objc func bassGuitarSliderChanged() {
		SoundPlayer.playerFor(instrumentType: .bassGuitar)?.setVolume(bassGuitarControl.value, fadeDuration: 0)
	}
	
	@objc func drumsSliderChanged() {
		SoundPlayer.playerFor(instrumentType: .drums)?.setVolume(drumsControl.value, fadeDuration: 0)
	}
	
	

}
