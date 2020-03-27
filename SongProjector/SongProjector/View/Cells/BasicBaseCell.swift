//
//  BasicBaseCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/02/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class BasicBaseCell: UITableViewCell {

	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var actionContainerView: UIView!
	@IBOutlet var actionImageView: UIImageView!
	@IBOutlet var actionButton: UIButton!
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
