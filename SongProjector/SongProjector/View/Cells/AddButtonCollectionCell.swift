//
//  AddButtonCollectionCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class AddButtonCollectionCell: UICollectionViewCell {

	@IBOutlet var titleDescription: UILabel!
	
	func setup(description: String)  {
		titleDescription.text = description
		titleDescription.textColor = themeHighlighted
	}
	
}
