//
//  SheetEmpty.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetEmpty: SheetView {
	
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var backgroundView: UIView!
	@IBOutlet var sheetView: UIView!
	@IBOutlet var timeLabel: UILabel!

	@IBOutlet var timeLabelTopConstraint: NSLayoutConstraint!
	@IBOutlet var timeLabelRightConstraint: NSLayoutConstraint!
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetEmpty", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	override func update() {
		timeLabel.text = ""

		if let scaleFactor = scaleFactor {
			
			timeLabelTopConstraint.constant = timeLabelTopConstraint.constant * scaleFactor
			timeLabelRightConstraint.constant = timeLabelRightConstraint.constant * scaleFactor

			updateBackgroundImage()
			updateBackgroundColor()
			updateOpacity()
			
		}
	}
	
	override func updateOpacity() {
		if let alpha = sheetTheme?.backgroundTransparancy, alpha != 1 {
			if sheetTheme?.backgroundImage != nil {
				backgroundImageView.alpha = CGFloat(alpha)
				backgroundView.alpha = 1
			} else {
				backgroundImageView.alpha = 0
				backgroundView.alpha = CGFloat(alpha)
			}
		}
	}
	
	override func updateBackgroundImage() {
		let image = isForExternalDispay ? sheetTheme?.backgroundImage : sheetTheme?.thumbnail
		if let backgroundImage = image, !(sheetTheme?.isBackgroundImageDeleted ?? true) {
			backgroundImageView.isHidden = false
			backgroundImageView.contentMode = .scaleAspectFill
			backgroundImageView.image = backgroundImage
			if let backgroundTransparency = sheetTheme?.backgroundTransparancy {
				backgroundImageView.alpha = CGFloat(backgroundTransparency)
			}
		} else {
			backgroundImageView.isHidden = true
		}
	}
	
	override func updateBackgroundColor() {
		if let backgroundColor = sheetTheme?.sheetBackgroundColor {
			self.backgroundView.backgroundColor = backgroundColor
		} else {
			self.backgroundView.backgroundColor = .white
		}
	}
	
	override func updateTime(isOn: Bool) {
		
		let test = Date().time
		if !isOn {
			timeLabel.text = ""
			return
		}
		
		if let theme = sheetTheme, let scaleFactor = scaleFactor { // is custom sheet
			
			timeLabel.attributedText = NSAttributedString(string: test, attributes: theme.getTitleAttributes(scaleFactor))
			
		} else {
			timeLabel.text = test
		}
		
	}
}
