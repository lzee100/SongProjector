//
//  TagCellCollection.swift
//  SongViewer
//
//  Created by Leo van der Zee on 13-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class TagCellCollection: UICollectionViewCell {
	
	@IBOutlet var icon: UIImageView!
	@IBOutlet var title: UILabel!
	
	var preferredWidth: CGFloat {
		title.setNeedsDisplay()
		return title.intrinsicContentSize.width
	}
	
	var isSelectedCell = false { didSet { update() } }
	private var tagName: String?
	
	func setup(tagName: String) {
		self.tagName = tagName
		update()
	}
	
	private func update() {
		title.text = tagName ?? ""
		if isSelectedCell {
			title.textColor = themeHighlighted
			icon.tintColor = themeHighlighted
		} else {
			title.textColor = themeWhiteBlackTextColor
			icon.tintColor = themeWhiteBlackTextColor
		}
		icon.image = isSelectedCell ? Cells.bulletFilled : Cells.bulletOpen
	}

	


}
