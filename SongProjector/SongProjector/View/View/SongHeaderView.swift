//
//  SongHeaderView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit


class SongHeaderView: UIView {

	@IBOutlet var songHeaderView: UIView!
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var headerButton: UIButton!
	@IBOutlet var pianoButton: UIButton!
	@IBOutlet var pianoCircleView: UIView!
	@IBOutlet var pianoIconView: UIImageView!
	@IBOutlet var mixerAnimationView: MixerAnimationView!
	
	private var customTextColor: UIColor?
	private var icon: UIImage?
	private var iconSelected: UIImage?
	private var isSelected = false
	var didSelectHeader: ((Int) -> Void)?
	var didSelectPiano: ((Int) -> Void)?
	var isPlayingPianoOnly: Bool {
		return pianoCircleView.layer.borderColor != themeWhiteBlackTextColor.cgColor
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("SongHeaderView", owner: self, options: [:])
		songHeaderView.frame = self.frame
		songHeaderView.backgroundColor = themeWhiteBlackBackground
		addSubview(songHeaderView)
		pianoCircleView.layer.borderWidth = 2
		pianoCircleView.layer.borderColor = themeWhiteBlackTextColor.cgColor
		pianoCircleView.layer.cornerRadius = pianoCircleView.bounds.width / 2
		pianoIconView.tintColor = themeWhiteBlackTextColor
		
	}
	
	func setup(title: String?, icon: UIImage? = nil, iconSelected: UIImage? = nil, textColor: UIColor? = nil, isSelected: Bool = false, tag: Int = 0, hasPianoSolo: Bool) {
		self.isSelected = isSelected
		self.iconImageView.image = icon
		self.iconSelected = iconSelected
		self.icon = icon
		self.customTextColor = textColor
		self.titleLabel.text = title
		self.headerButton.tag = tag
		self.pianoButton.tag = tag
		self.pianoButton.isEnabled = hasPianoSolo
		self.pianoCircleView.isHidden = !hasPianoSolo
		self.pianoIconView.isHidden = !hasPianoSolo
		update()
	}
	
	func update() {
		self.iconImageView.image = isSelected ? (iconSelected ?? icon) : icon
		self.iconImageView.tintColor = isSelected ? themeHighlighted : themeWhiteBlackTextColor
		self.titleLabel.textColor = isSelected ? themeHighlighted : themeWhiteBlackTextColor
	}
	
	func togglePianoPlay() {
		let isWhite = pianoCircleView.layer.borderColor == themeWhiteBlackTextColor.cgColor
		pianoCircleView.layer.borderColor = isWhite ? themeHighlighted.cgColor : themeWhiteBlackTextColor.cgColor
		pianoIconView.tintColor = isWhite ? themeHighlighted : themeWhiteBlackTextColor
		if isWhite {
			pianoIconView.isHidden = true
			mixerAnimationView.isHidden = false
			mixerAnimationView.play()
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.pianoIconView.isHidden = false
				self.mixerAnimationView.isHidden = true
			}
			mixerAnimationView.stop()
		}
	}
	
	
	@IBAction func songHeaderViewPressed(_ sender: UIButton) {
		didSelectHeader?(sender.tag)
	}
	
	@IBAction func pianoPressed(_ sender: UIButton) {
		togglePianoPlay()
		didSelectPiano?(sender.tag)
	}
	
}
