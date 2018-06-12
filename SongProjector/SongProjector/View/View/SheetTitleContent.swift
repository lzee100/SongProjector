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
	
	var songTitle: String? { return cluster?.title ?? sheet.title }
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

				if let songTitle = songTitle {
					if let tag = sheetTag { // is custom sheet
						
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
						titleLabel.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes(scaleFactor))
						updateTime(isOn: tag.displayTime)
					} else {
						titleLabel.text = songTitle
					}
				}
				if let lyrics = lyrics {
					if let tag = sheetTag {
						lyricsTextView.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
					} else {
					lyricsTextView.text = lyrics
					}
				}
			}
			
			if let backgroundColor = sheetTag?.sheetBackgroundColor, sheetTag?.imagePath == nil {
				self.sheetBackground.backgroundColor = backgroundColor
			} else {
				sheetBackground.backgroundColor = .white
			}
			
			setBackgroundImage(image: isForExternalDispay ? sheetTag?.backgroundImage : sheetTag?.thumbnail)
			
			if let titleBackgroundColor = sheetTag?.backgroundColorTitle, let title = sheetTag?.title, title != "" {
				if let allHaveTitle = sheetTag?.allHaveTitle, allHaveTitle == false && position < 1 {
					titleBackground.isHidden = false
					titleBackground.backgroundColor = titleBackgroundColor
				} else if  let allHaveTitle = sheetTag?.allHaveTitle, allHaveTitle == true {
					titleBackground.isHidden = false
					titleBackground.backgroundColor = titleBackgroundColor
				} else {
					titleBackground.isHidden = true
				}
			} else {
				titleBackground.isHidden = true
			}
			
		}
	}
	
	override func changeOpacity(newValue: Float) {
		if let _ = isForExternalDispay ? sheetTag?.backgroundImage : sheetTag?.thumbnail {
			sheetBackground.backgroundColor = .black
			backgroundImageView.alpha = CGFloat(newValue)
		}
	}
	
	override func setBackgroundImage(image: UIImage?) {
		
		if let backgroundImage = image {
			backgroundImageView.isHidden = false
			backgroundImageView.contentMode = .scaleAspectFill
			backgroundImageView.image = backgroundImage
			backgroundImageView.clipsToBounds = true
			if let backgroundTransparency = sheetTag?.backgroundTransparency {
				sheetBackground.backgroundColor = .black
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
		
		if let tag = sheetTag, let scaleFactor = scaleFactor { // is custom sheet
			
			timeLabel.attributedText = NSAttributedString(string: test, attributes: tag.getTitleAttributes(scaleFactor))

		} else {
			timeLabel.text = test
		}
		
	}
	
}
