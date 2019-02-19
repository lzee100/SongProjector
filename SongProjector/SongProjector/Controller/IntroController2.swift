//
//  IntroController2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class IntroController2: PageController {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!
	
	@IBOutlet var collectionView: UICollectionView!
	
	@IBOutlet var titleRightConstraint: NSLayoutConstraint!
	@IBOutlet var contentLeftConstraint: NSLayoutConstraint!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	

}

class AboOptionCell: UICollectionViewCell {
	
	@IBOutlet var backgroundColorView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var featureOne: UILabel!
	@IBOutlet var featureTwo: UILabel!
	@IBOutlet var featureThree: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	func apply(title: String, feature1: String, feature2: String, feature3: String, buttonText: String) {
		
	}
	
}
