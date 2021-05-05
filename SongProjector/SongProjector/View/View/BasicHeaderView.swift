//
//  BasicHeaderView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/10/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class BasicHeaderView: UITableViewHeaderFooterView {

    static let identifier = "BasicHeaderView"
    static let height: CGFloat = 50

    @IBOutlet var descriptionLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionLabel.textColor = .blackColor
        descriptionLabel.font = .largeBold
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .whiteColor
        backgroundView = view
    }

}
