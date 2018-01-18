//
//  SheetTitleContent.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetTitleContent: SheetView {
	
	@IBOutlet var sheetView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var titleBackground: UIView!
	@IBOutlet var lyricsTextView: UITextView!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var sheetBackground: UIView!
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
	@IBOutlet var titleRightConstraint: NSLayoutConstraint!
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
			lyricsTextView.backgroundColor = .clear
			
			if isEmptySheet {
				songTitle = nil
				lyrics = nil
				titleLabel.text = ""
				lyricsTextView.text = ""
			}else {
				titleLeftConstraint.constant = titleLeftConstraint.constant * scaleFactor
				titleTopConstraint.constant = titleTopConstraint.constant * scaleFactor
				titleRightConstraint.constant = titleRightConstraint.constant * scaleFactor
				lyricsLeftConstraint.constant = lyricsLeftConstraint.constant * scaleFactor
				lyricsBottomConstraint.constant = lyricsBottomConstraint.constant * scaleFactor
				lyricsRightConstraint.constant = lyricsRightConstraint.constant * scaleFactor
				
				if let songTitle = songTitle {
					
					if let tag = selectedTag {
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
			
			if let backgroundImage = selectedTag?.backgroundImage, let imageScaled = UIImage.scaleImageToSize(image: backgroundImage, size: bounds.size) {
				imageScaled.draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
				backgroundImageView.isHidden = false
				backgroundImageView.contentMode = .scaleAspectFit
				backgroundImageView.image = imageScaled
			} else {
				backgroundImageView.isHidden = true
			}
			
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

			if let backgroundColor = selectedTag?.sheetBackgroundColor {
				self.sheetBackground.backgroundColor = backgroundColor
			} else {
				sheetBackground.backgroundColor = .white
			}
			
		}
	}

}
