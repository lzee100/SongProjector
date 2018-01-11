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
	@IBOutlet var iconWidthContraint: NSLayoutConstraint!
	@IBOutlet var iconLeftConstraint: NSLayoutConstraint!
	
	var iconImage: UIImage?
	var iconSelected: UIImage?
	var selectedCell = false { didSet { update() } }
	var isLast = false { didSet { update() } }
	var isInnerCell = false { didSet { update() } }
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	func setup(title: String?, icon: UIImage? = nil, iconSelected: UIImage? = nil) {
		self.iconImage = icon
		self.iconSelected = iconSelected
		self.icon.image = icon
		self.title.text = title
		update()
	}
	
	private func update() {
		seperator.backgroundColor = .clear
		self.title.font = .xNormal
		if selectedCell {
			title.textColor = themeHighlighted
			icon.tintColor = themeHighlighted
			icon.image = iconSelected ?? iconImage
		} else {
			title.textColor = themeWhiteBlackTextColor
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

