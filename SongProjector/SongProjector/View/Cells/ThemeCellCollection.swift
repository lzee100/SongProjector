//
//  ThemeCellCollection.swift
//  SongViewer
//
//  Created by Leo van der Zee on 13-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class ThemeCellCollection: UICollectionViewCell {
	
    @IBOutlet var tagBackgroundView: UIView!
    @IBOutlet var title: UILabel!
	
	var preferredWidth: CGFloat {
		title.setNeedsDisplay()
		return title.intrinsicContentSize.width
	}
	
	var isSelectedCell = false { didSet { update() } }
	private var themeName: String?
	
	func setup(themeName: String) {
		self.themeName = themeName
		update()
	}
	
	private func update() {
        tagBackgroundView.layer.cornerRadius = 5
		title.text = themeName ?? ""
        tagBackgroundView.backgroundColor = isSelectedCell ? .softBlueGrey : .grey0
        title.textColor = isSelectedCell ? .white : .blackColor
	}

	


}
