//
//  MenuCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/10/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    static let identifier = "MenuCell"
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.font = .xNormal
        iconImageView.tintColor = .blackColor
        let v = UIView()
        v.backgroundColor = .grey0
        selectedBackgroundView = v
        
    }

    func setupWith(_ feature: Feature) {
        descriptionLabel.text = feature.titleForDisplay
        iconImageView.image = feature.image.normal
    }
    
}
