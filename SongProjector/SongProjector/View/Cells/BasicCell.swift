//
//  BasicCell.swift
//  SongViewer
//
//  Created by Leo van der Zee on 04-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class BasicCell: UITableViewCell {
	
	@IBOutlet var icon: UIImageView!
	@IBOutlet var title: UILabel!
	@IBOutlet var seperator: UIView!
	@IBOutlet var pianoCircleView: UIView!
	@IBOutlet var pianoIcon: UIImageView!
	@IBOutlet var iconWidthContraint: NSLayoutConstraint!
	@IBOutlet var iconLeftConstraint: NSLayoutConstraint!
	
	var iconImage: UIImage?
	var iconSelected: UIImage?
	var selectedCell = false { didSet { update() } }
	var isInnerCell = false { didSet { update() } }
	var customTextColor: UIColor?
	var data: Any?
	
	static let identifier = "BasicCell"
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		pianoCircleView.layer.borderWidth = 2
		pianoCircleView.layer.borderColor = themeWhiteBlackTextColor.cgColor
		pianoCircleView.layer.cornerRadius = pianoCircleView.bounds.width / 2
		pianoIcon.tintColor = themeWhiteBlackTextColor
	}
	
	func setup(title: String?, icon: UIImage? = nil, iconSelected: UIImage? = nil, textColor: UIColor? = nil, hasPianoOnly: Bool = false) {
		self.iconImage = icon
		self.iconSelected = iconSelected
		self.icon.image = icon
		self.customTextColor = textColor
		self.title.text = title
		pianoIcon.isHidden = !hasPianoOnly
		pianoCircleView.isHidden = !hasPianoOnly
		update()
	}
	
	private func update() {
		seperator.backgroundColor = .clear
		self.title.font = .xNormal
		if selectedCell {
			title.textColor = customTextColor ?? themeHighlighted
			icon.tintColor = themeHighlighted
			icon.image = iconSelected ?? iconImage
		} else {
			title.textColor = customTextColor ?? themeWhiteBlackTextColor
			icon.tintColor = themeWhiteBlackTextColor
			icon.image = iconImage
		}
		if icon == nil {
			iconWidthContraint.constant = 0
		}
		iconLeftConstraint.constant = isInnerCell ? 50 : 30
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
	
}

