//
//  SheetCollectionCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class SheetCollectionCell: UICollectionViewCell {

	@IBOutlet var sheetView: UIImageView!
	
	func setupWith(image: UIImage) {
		sheetView.image = image
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
