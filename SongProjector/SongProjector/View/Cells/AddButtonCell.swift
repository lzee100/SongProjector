//
//  AddButtonCell.swift
//  SongViewer
//
//  Created by Leo van der Zee on 08-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class AddButtonCell: ChurchBeamCell {

	static let identifier = "AddButtonCell"
	
	@IBOutlet var titleLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		titleLabel.textColor = themeHighlighted
	}
	
	func apply(title: String) {
		titleLabel.text = title
	}
}
