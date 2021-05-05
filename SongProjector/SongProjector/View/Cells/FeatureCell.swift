//
//  FeatureCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class FeatureCell: UITableViewCell {
    
    static let identifier = "FeatureCell"

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.font = .xNormal
        iconImageView.tintColor = .white
        descriptionLabel.textColor = .white
        backgroundColor = .clear
    }

    func apply(description: String, icon: UIImage) {
        descriptionLabel.text = description
        iconImageView.image = icon
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
}
