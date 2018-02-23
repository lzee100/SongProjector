//
//  HeaderView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class HeaderView: UIView {
	
	@IBOutlet var headerView: UIView!
	@IBOutlet var descriptionLabel: UILabel!
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("HeaderView", owner: self, options: [:])
		addSubview(headerView)
		headerView.frame = bounds
		descriptionLabel.textColor = themeHighlighted
		headerView.backgroundColor = isThemeLight ? UIColor(hex: "F0F0F2") : UIColor(hex: "101010")

	}
	
}
