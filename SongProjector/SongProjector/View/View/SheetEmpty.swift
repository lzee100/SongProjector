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
	
	
	private var selectedTag: Tag?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetEmpty", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	static func createWith(frame: CGRect, tag: Tag?, scaleFactor: CGFloat = 1) -> SheetEmpty {
		
		let view = SheetEmpty(frame: frame)
		view.selectedTag = tag
		view.scaleFactor = scaleFactor
		view.timeLabel.text = ""

		view.update()
		
		return view
	}
	
	override func update() {
		
		if let scaleFactor = scaleFactor, scaleFactor > 1 {

			timeLabelTopConstraint.constant = (timeLabelTopConstraint.constant / UIScreen.main.scale) * scaleFactor
			timeLabelRightConstraint.constant = (timeLabelRightConstraint.constant / UIScreen.main.scale) * scaleFactor
		}
		setBackgroundImage(image: isForExternalDispay ? selectedTag?.backgroundImage : selectedTag?.thumbnail)
		
		if let backgroundColor = selectedTag?.sheetBackgroundColor, selectedTag?.backgroundImage == nil {
			self.backgroundView.backgroundColor = backgroundColor
		} else {
			self.backgroundView.backgroundColor = .white
		}
	}
	
	override func changeOpacity(newValue: Float) {
		if let _ = isForExternalDispay ? selectedTag?.backgroundImage : selectedTag?.thumbnail {
			backgroundImageView.alpha = CGFloat(newValue)
		}
	}
	
	override func setBackgroundImage(image: UIImage?) {
		if let backgroundImage = image {
			backgroundImageView.isHidden = false
			backgroundImageView.contentMode = .scaleAspectFill
			backgroundImageView.image = backgroundImage
			if let backgroundTransparency = selectedTag?.backgroundTransparency {
				backgroundImageView.alpha = CGFloat(backgroundTransparency)
			}
		} else {
			backgroundImageView.isHidden = true
		}
	}
	
	override func updateTime(isOn: Bool) {
		
		let test = Date().time
		if !isOn {
			timeLabel.text = ""
			return
		}
		
		if let tag = selectedTag, let scaleFactor = scaleFactor { // is custom sheet
			
			timeLabel.attributedText = NSAttributedString(string: test, attributes: tag.getTitleAttributes(scaleFactor))
			
		} else {
			timeLabel.text = test
		}
		
	}
}
