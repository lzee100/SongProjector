//
//  TextCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/07/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

	
	@IBOutlet var bottomConstraint: NSLayoutConstraint!
	@IBOutlet var topConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionLabel: UILabel!
	
	static let identifier = "TextCell"
	
	override func awakeFromNib() {
        super.awakeFromNib()
		descriptionLabel.textColor = themeWhiteBlackTextColor
		contentView.backgroundColor = themeWhiteBlackBackground
    }
	
	func setupWith(text: String, hasTopMargin: Bool = true, hasBottomMargin: Bool = true) {
		descriptionLabel.text = text
		topConstraint.constant = hasTopMargin ? 8 : 0
		bottomConstraint.constant = hasBottomMargin ? 8 : 0
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
    
}
