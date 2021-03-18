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
        if [sheetTheme?.displayTime, cluster?.hasTheme(moc: moc)?.displayTime].compactMap({ $0 }).contains(true) {
            updateTime(isOn: true)
        }
	}
	
	override func updateOpacity() {
        let image = isForExternalDispay ? sheetTheme?.tempSelectedImage ?? sheetTheme?.backgroundImage : sheetTheme?.tempSelectedImageThumbNail ?? sheetTheme?.thumbnail
        if let alpha = sheetTheme?.backgroundTransparancy {
            if image != nil, !(sheetTheme?.isTempSelectedImageDeleted ?? true) {
                backgroundImageView.alpha = CGFloat(alpha)
                backgroundView.alpha = 1
            } else {
                backgroundImageView.alpha = 0
                backgroundView.alpha = CGFloat(alpha)
            }
        }
	}
	
	override func updateBackgroundImage() {
        let image = isForExternalDispay ? sheetTheme?.tempSelectedImage ?? sheetTheme?.backgroundImage : sheetTheme?.tempSelectedImageThumbNail ?? sheetTheme?.thumbnail
        if let backgroundImage = image, !(sheetTheme?.isTempSelectedImageDeleted ?? true) {
            backgroundImageView.isHidden = false
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.image = backgroundImage
            backgroundImageView.clipsToBounds = true
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
			var attributes = theme.getTitleAttributes(scaleFactor)
            if !theme.displayTime, let font = UIFont(name: "Avenir", size: 10 * scaleFactor) {
                attributes[NSAttributedString.Key.foregroundColor] = UIColor.white
                attributes[NSAttributedString.Key.font] = font
            }
			timeLabel.attributedText = NSAttributedString(string: test, attributes: attributes)
			
		} else if let font = UIFont(name: "Avenir", size: 10 * (scaleFactor ?? 1)) {
            timeLabel.attributedText = NSAttributedString(string: test, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : font])
		}
		
	}
}
