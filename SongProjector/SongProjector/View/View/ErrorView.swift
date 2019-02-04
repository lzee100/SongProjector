//
//  ErrorView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class ErrorView: UIView {

	@IBOutlet var errorView: UIView!
	
	@IBOutlet var titleLabel: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	init(frame: CGRect, message: String, height: CGFloat) {
		super.init(frame: frame)
		customInit()
		self.titleLabel.text = message
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("ErrorView", owner: self, options: [:])
		addSubview(errorView)
		errorView.frame = bounds
		let effect = isThemeLight ? UIBlurEffectStyle.dark : UIBlurEffectStyle.light
		let blurEffect = UIBlurEffect(style: effect)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.layer.cornerRadius = 10
		blurEffectView.frame = bounds
		blurEffectView.clipsToBounds = true
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.addSubview(blurEffectView)
		sendSubview(toBack: blurEffectView)
		
		errorView.backgroundColor = UIColor.clear
		errorView.clipsToBounds = true
		titleLabel.textColor = themeWhiteBlackTextColor
		errorView.layer.cornerRadius = 10
		titleLabel.font = UIFont.systemFont(ofSize: 14)
		
	}

}
