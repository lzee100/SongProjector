//
//  TextFooterView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

final class TextFooterView: UITableViewHeaderFooterView {
    static let identifier: String = "TextFooterView"

    var descriptionLabel: UILabel

    override init(reuseIdentifier: String?) {
        descriptionLabel = UILabel()
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        descriptionLabel.font = .small
        descriptionLabel.textColor = .grey3
        
    }
    
    func setup(description: String) {
        descriptionLabel.text = description
    }

    required init?(coder aDecoder: NSCoder) {
        descriptionLabel = UILabel()
        super.init(coder: aDecoder)
    }
}
