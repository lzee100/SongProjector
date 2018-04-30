//
//  SheetTitleContent.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import SwiftOCR

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
	
	var songTitle: String?
	var lyrics: String?
	var selectedTag: Tag?
	var isEmptySheet: Bool = false
	var position = 0
	var zeroHeightConstraint: NSLayoutConstraint?
	
	static func createWith(frame: CGRect, title: String?, sheet: SheetTitleContentEntity?, tag: Tag?, scaleFactor: CGFloat? = 1) -> SheetTitleContent {
		let sheetTitleContent = SheetTitleContent(frame: frame)
		sheetTitleContent.isEmptySheet = sheet?.title == Text.Sheet.emptySheetTitle
		sheetTitleContent.selectedTag = tag
		sheetTitleContent.songTitle = title
		sheetTitleContent.lyrics = sheet?.lyrics
		sheetTitleContent.timeLabel.text = ""
		sheetTitleContent.position = Int(sheet?.position ?? 0)
		sheetTitleContent.scaleFactor = scaleFactor
		sheetTitleContent.update()
		return sheetTitleContent
	}
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetTitleContent", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	override func update() {
		if let scaleFactor = scaleFactor {
			
			if scaleFactor != 1 {
				titleLeftConstraint.constant = (titleLeftConstraint.constant / UIScreen.main.scale) * scaleFactor
				titleTopConstraint.constant = (titleTopConstraint.constant / UIScreen.main.scale) * scaleFactor
				timeRightConstraint.constant = (timeRightConstraint.constant / UIScreen.main.scale) * scaleFactor
				lyricsLeftConstraint.constant = (lyricsLeftConstraint.constant / UIScreen.main.scale) * scaleFactor
				lyricsBottomConstraint.constant = (lyricsBottomConstraint.constant / UIScreen.main.scale) * scaleFactor
				lyricsRightConstraint.constant = (lyricsRightConstraint.constant / UIScreen.main.scale) * scaleFactor
			}

			lyricsTextView.backgroundColor = .clear
			
			if isEmptySheet {
				songTitle = nil
				lyrics = nil
				titleLabel.text = ""
				lyricsTextView.text = ""
			} else {

				if let songTitle = songTitle {
					if let tag = selectedTag { // is custom sheet
						
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
					if let tag = selectedTag {
						lyricsTextView.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
					} else {
					lyricsTextView.text = lyrics
					}
				}
			}
			
			if let backgroundColor = selectedTag?.sheetBackgroundColor, selectedTag?.imagePath == nil {
				self.sheetBackground.backgroundColor = backgroundColor
			} else {
				sheetBackground.backgroundColor = .white
			}
			
			setBackgroundImage(image: isForExternalDispay ? selectedTag?.backgroundImage : selectedTag?.thumbnail)
			
			if let titleBackgroundColor = selectedTag?.backgroundColorTitle, let title = selectedTag?.title, title != "" {
				if let allHaveTitle = selectedTag?.allHaveTitle, allHaveTitle == false && position < 1 {
					titleBackground.isHidden = false
					titleBackground.backgroundColor = titleBackgroundColor
				} else if  let allHaveTitle = selectedTag?.allHaveTitle, allHaveTitle == true {
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
		if let _ = isForExternalDispay ? selectedTag?.backgroundImage : selectedTag?.thumbnail {
			sheetBackground.backgroundColor = .black
			backgroundImageView.alpha = CGFloat(newValue)
		}
	}
	
	override func setBackgroundImage(image: UIImage?) {
		
		if let backgroundImage = image {
			backgroundImageView.isHidden = false
			backgroundImageView.contentMode = .scaleAspectFill
			backgroundImageView.image = backgroundImage
			if let backgroundTransparency = selectedTag?.backgroundTransparency {
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
		
		if let tag = selectedTag, let scaleFactor = scaleFactor { // is custom sheet
			
			timeLabel.attributedText = NSAttributedString(string: test, attributes: tag.getTitleAttributes(scaleFactor))

		} else {
			timeLabel.text = test
		}
		
	}
	
}
