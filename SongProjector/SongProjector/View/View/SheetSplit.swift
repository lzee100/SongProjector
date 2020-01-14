//
//  SheetSplit.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetSplit: SheetView {
	
	@IBOutlet var sheetBackgroundView: UIView!
	@IBOutlet var sheetBackgroundImageView: UIImageView!
	@IBOutlet var timeLabel: UILabel!

	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
	@IBOutlet var timeLabelRightConstraint: NSLayoutConstraint!
	
	@IBOutlet var containerTopConstraint: NSLayoutConstraint!
	@IBOutlet var containerRightConstraint: NSLayoutConstraint!
	@IBOutlet var containerBottomConstraint: NSLayoutConstraint!
	@IBOutlet var containerLeftConstraint: NSLayoutConstraint!
	
	@IBOutlet var sheetView: UIView!
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var titleBackgroundView: UIView!
	
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var textViewLeft: UITextView!
	@IBOutlet var textViewRight: UITextView!
	
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	
	private var zeroHeightConstraint: NSLayoutConstraint?
	private var newTitleBottomConstraint: NSLayoutConstraint?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetSplit", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	override func update() {
		timeLabel.text = ""
		if let scaleFactor = scaleFactor {
			
			titleLeftConstraint.constant = titleLeftConstraint.constant * scaleFactor
			titleTopConstraint.constant = titleTopConstraint.constant * scaleFactor
			timeLabelRightConstraint.constant = timeLabelRightConstraint.constant * scaleFactor
			containerTopConstraint.constant = containerTopConstraint.constant * scaleFactor
			containerRightConstraint.constant = containerRightConstraint.constant * scaleFactor
			containerBottomConstraint.constant = containerBottomConstraint.constant * scaleFactor
			containerLeftConstraint.constant = containerLeftConstraint.constant * scaleFactor
			titleHeightConstraint.constant = titleHeightConstraint.constant * scaleFactor
			
			updateTitle()
			updateContent()
			updateBackgroundImage()
			updateOpacity()
			updateBackgroundColor()
			self.layoutIfNeeded()
		}
	}
	
	override func updateTitle() {
		if let songTitle = self.sheet.title {
			if let theme = sheetTheme {
				
				if let zeroHeightConstraint = zeroHeightConstraint {
					descriptionTitle.removeConstraint(zeroHeightConstraint)
				}
				if let newTitleBottomConstraint = newTitleBottomConstraint {
					descriptionTitle.removeConstraint(newTitleBottomConstraint)
				}
				
				// reset height constraint
				titleHeightConstraint.isActive = true
				
				descriptionTitle.attributedText = NSAttributedString(string: songTitle, attributes: theme.getTitleAttributes(scaleFactor ?? 1))
			} else {
				descriptionTitle.text = songTitle
			}
		} else {
			// set height constraint to zero
			titleHeightConstraint.isActive = false
			zeroHeightConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
			descriptionTitle.addConstraint(zeroHeightConstraint!)
		}
	}
	
	override func updateContent() {
		let sheet = self.sheet as! VSheetSplit
		if let content = sheet.textLeft {
			if let theme = sheetTheme {
				textViewLeft.attributedText = NSAttributedString(string: content, attributes: theme.getLyricsAttributes(scaleFactor ?? 1))
			} else {
				textViewLeft.text = content
			}
		} else {
			textViewLeft.text = nil
		}
		if let content = sheet.textRight {
			if let theme = sheetTheme {
				textViewRight.attributedText = NSAttributedString(string: content, attributes: theme.getLyricsAttributes(scaleFactor ?? 1))
			} else {
				textViewRight.text = content
			}
		} else {
			textViewRight.text =  nil
		}
	}
	
	override func updateOpacity() {
		if let alpha = sheetTheme?.backgroundTransparancy, alpha != 1 {
			if sheetTheme?.backgroundImage != nil {
				sheetBackgroundImageView.alpha = CGFloat(alpha)
				sheetBackgroundView.alpha = 1
			} else {
				sheetBackgroundImageView.alpha = 0
				sheetBackgroundView.alpha = CGFloat(alpha)
			}
		}
	}
	
	override func updateBackgroundColor() {
		if let titleBackgroundColor = sheetTheme?.backgroundColorTitle, let title = sheetTheme?.title, title != "" {
			if let allHaveTitle = sheetTheme?.allHaveTitle, allHaveTitle == false && position < 1 {
				titleBackgroundView.isHidden = false
				titleBackgroundView.backgroundColor = titleBackgroundColor
			} else if  let allHaveTitle = sheetTheme?.allHaveTitle, allHaveTitle == true {
				titleBackgroundView.isHidden = false
				titleBackgroundView.backgroundColor = titleBackgroundColor
			} else {
				titleBackgroundView.isHidden = true
			}
		} else {
			titleBackgroundView.isHidden = true
		}
		
		if let backgroundColor = sheetTheme?.sheetBackgroundColor {
			self.sheetBackgroundView.backgroundColor = backgroundColor
		} else {
			self.sheetBackgroundView.backgroundColor = .white
		}
	}
	
	override func updateBackgroundImage() {
		let image = isForExternalDispay ? sheetTheme?.backgroundImage : sheetTheme?.thumbnail
		if let backgroundImage = image, !(sheetTheme?.isBackgroundImageDeleted ?? true) {
			sheetBackgroundImageView.isHidden = false
			sheetBackgroundImageView.contentMode = .scaleAspectFill
			sheetBackgroundImageView.image = backgroundImage
			if let backgroundTransparency = sheetTheme?.backgroundTransparancy {
				sheetBackgroundImageView.alpha = CGFloat(backgroundTransparency)
			}
		} else {
			sheetBackgroundImageView.isHidden = true
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
