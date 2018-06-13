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
	
	private var customTextColor: UIColor?
	private var icon: UIImage?
	private var iconSelected: UIImage?
	private var isSelected = false
	var didSelectHeader: ((Int) -> Void)?
	
	
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
	}
	
	func setup(title: String?, icon: UIImage? = nil, iconSelected: UIImage? = nil, textColor: UIColor? = nil, isSelected: Bool = false, tag: Int = 0) {
		self.isSelected = isSelected
		self.iconImageView.image = icon
		self.iconSelected = iconSelected
		self.icon = icon
		self.customTextColor = textColor
		self.titleLabel.text = title
		self.headerButton.tag = tag
		update()
	}
	
	func update() {
		self.iconImageView.image = isSelected ? (iconSelected ?? icon) : icon
		self.iconImageView.tintColor = isSelected ? themeHighlighted : themeWhiteBlackTextColor
		self.titleLabel.textColor = isSelected ? themeHighlighted : themeWhiteBlackTextColor
	}
	
	
	@IBAction func songHeaderViewPressed(_ sender: UIButton) {
		didSelectHeader?(sender.tag)
	}
	
}
