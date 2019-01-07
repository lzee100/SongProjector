//
//  SheetTitleContent.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import SwiftOCR
import MessageUI

class SheetTitleContent: SheetView {
	
	@IBOutlet var sheetView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var titleBackground: UIView!
	@IBOutlet var lyricsTextView: UITextView!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var sheetBackground: UIView!
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
	@IBOutlet var timeRightConstraint: NSLayoutConstraint!
	@IBOutlet var lyricsLeftConstraint: NSLayoutConstraint!
	@IBOutlet var lyricsRightConstraint: NSLayoutConstraint!
	@IBOutlet var lyricsBottomConstraint: NSLayoutConstraint!
	@IBOutlet var lyricsTopToTitle: NSLayoutConstraint!
	
	var songTitle: String? {
		if ((sheetTheme?.allHaveTitle ?? true) || position == 0) {
			return cluster?.title ?? sheet.title ?? sheetTheme?.title
		} else {
			return nil
		}
	}
	var lyrics: String? {
		if let sheet = sheet as? SheetTitleContentEntity {
			return sheet.lyrics
		}
		return nil
	}
	var zeroHeightConstraint: NSLayoutConstraint?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetTitleContent", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	override func update() {
		timeLabel.text = ""
		
		if let scaleFactor = scaleFactor {
			
			titleLeftConstraint.constant = titleLeftConstraint.constant * scaleFactor
			titleTopConstraint.constant = titleTopConstraint.constant * scaleFactor
			timeRightConstraint.constant = timeRightConstraint.constant * scaleFactor
			lyricsLeftConstraint.constant = lyricsLeftConstraint.constant * scaleFactor
			lyricsBottomConstraint.constant = lyricsBottomConstraint.constant * scaleFactor
			lyricsRightConstraint.constant = lyricsRightConstraint.constant * scaleFactor
			lyricsTopToTitle.constant = lyricsTopToTitle.constant * scaleFactor

			lyricsTextView.backgroundColor = .clear
			
			if sheet.isEmptySheet {
				titleLabel.text = ""
				lyricsTextView.text = ""
			} else {

				updateTitle()
				
			}
			
			updateContent()
			updateBackgroundImage()
			updateBackgroundColor()
			updateOpacity()
			
		}
	}
	
	override func updateTitle() {
		if let songTitle = songTitle {
			if let tag = sheetTheme { // is custom sheet
				
				if !tag.allHaveTitle && position > 0 {
					titleHeightConstraint.isActive = false
					zeroHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
					titleLabel.addConstraint(zeroHeightConstraint!)
				} else {
					if let zeroHeightConstraint = zeroHeightConstraint {
						titleLabel.removeConstraint(zeroHeightConstraint)
					}
					titleHeightConstraint.isActive = true
				}
				titleLabel.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes(scaleFactor ?? 1))
				updateTime(isOn: tag.displayTime)
			} else {
				titleLabel.text = songTitle
			}
		} else {
			titleLabel.text = nil
		}
	}
	
	override func updateContent() {
		let sheet = self.sheet as! SheetTitleContentEntity
		if let lyrics = sheet.lyrics {
			if let tag = sheetTheme {
				lyricsTextView.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor ?? 1))
			} else {
				lyricsTextView.text = lyrics
			}
		} else {
			lyricsTextView.text = nil
		}
	}
	
	
	
	override func updateOpacity() {
		if let alpha = sheetTheme?.backgroundTransparency, alpha != 1 {
			backgroundImageView.alpha = CGFloat(alpha)
		}
	}
	
	override func updateBackgroundImage() {
		let image = isForExternalDispay ? sheetTheme?.backgroundImage : sheetTheme?.thumbnail
		if let backgroundImage = image, !(sheetTheme?.isBackgroundImageDeleted ?? true) {
			backgroundImageView.isHidden = false
			backgroundImageView.contentMode = .scaleAspectFill
			backgroundImageView.image = backgroundImage
			backgroundImageView.clipsToBounds = true
			if let backgroundTransparency = sheetTheme?.backgroundTransparency {
				backgroundImageView.alpha = CGFloat(backgroundTransparency)
			}
		} else {
			backgroundImageView.isHidden = true
		}
	}
	
	override func updateBackgroundColor() {
		if let titleBackgroundColor = sheetTheme?.backgroundColorTitle, let title = sheetTheme?.title, title != "" {
			if let allHaveTitle = sheetTheme?.allHaveTitle, allHaveTitle == false && position < 1 {
				titleBackground.isHidden = false
				titleBackground.backgroundColor = titleBackgroundColor
			} else if  let allHaveTitle = sheetTheme?.allHaveTitle, allHaveTitle == true {
				titleBackground.isHidden = false
				titleBackground.backgroundColor = titleBackgroundColor
			} else {
				titleBackground.isHidden = true
			}
		} else {
			titleBackground.isHidden = true
		}
		
		if let backgroundColor = sheetTheme?.sheetBackgroundColor {
			self.sheetBackground.backgroundColor = backgroundColor
		} else {
			self.sheetBackground.backgroundColor = .white
		}
	}
	
	override func updateTime(isOn: Bool) {
		
		let test = Date().time
		if !isOn {
			timeLabel.text = ""
			return
		}
		
		if let tag = sheetTheme, let scaleFactor = scaleFactor { // is custom sheet
			
			timeLabel.attributedText = NSAttributedString(string: test, attributes: tag.getTitleAttributes(scaleFactor))

		} else {
			timeLabel.text = test
		}
		
	}
	
}
