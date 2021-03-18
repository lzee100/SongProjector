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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.first(where: { $0.tag == 2 })?.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.font = .xNormal
        descriptionLabel.textColor = .blackColor
        subviews.first(where: { $0.tag == 2 })?.removeFromSuperview()
    }
	
	override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.font = .xNormal
		descriptionLabel.textColor = .blackColor
        contentView.backgroundColor = .clear
    }
	
	func setupWith(text: String, hasTopMargin: Bool = true, hasBottomMargin: Bool = true) {
		descriptionLabel.text = text
		topConstraint.constant = hasTopMargin ? 15 : 0
		bottomConstraint.constant = hasBottomMargin ? 15 : 0
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
    
    func asSmallHeader() {
        topConstraint.constant = 15
        bottomConstraint.constant = 4
        descriptionLabel.font = .xNormalBold
        descriptionLabel.textColor = .softBlueGrey
    }
    
}
