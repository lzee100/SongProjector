//
//  SheetView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetView: UIView {
	
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
	var scaleFactor: CGFloat = 1
	var isEditable = false
	
	var previewTitleAttributes: [NSAttributedStringKey: Any]?
	var previewLyricsAttributes: [NSAttributedStringKey: Any]?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("SheetController", owner: self, options: [:])
		addSubview(sheetView)
		sheetView.frame = bounds
	}
	
	func update() {
		
		titleLabel.isEnabled = isEditable
		lyricsTextView.isEditable = isEditable
		lyricsTextView.isSelectable = isEditable
		
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
				if var previewTitleAttributes = previewTitleAttributes {
					if let font = previewTitleAttributes[.font] as? UIFont {
						previewTitleAttributes[.font] = UIFont(name: font.fontName, size: font.pointSize * scaleFactor)
					}
					titleLabel.attributedText = NSAttributedString(string: songTitle, attributes: previewTitleAttributes)
				} else if let tag = selectedTag {
					titleLabel.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes(scaleFactor))
				} else {
					titleLabel.text = songTitle
				}
			}
			
			if let lyrics = lyrics {
				if var previewLyricsAttributes = previewLyricsAttributes {
					if let font = previewLyricsAttributes[.font] as? UIFont {
						previewLyricsAttributes[.font] = UIFont(name: font.fontName, size: font.pointSize * scaleFactor)
					}
					lyricsTextView.attributedText = NSAttributedString(string: lyrics, attributes: previewLyricsAttributes)
				} else if let tag = selectedTag {
					lyricsTextView.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
				} else {
				lyricsTextView.text = lyrics
				}
			}
		}
		
		if let backgroundImage = selectedTag?.backgroundImage, let imageScaled = UIImage.scaleImageToSize(image: backgroundImage, size: frame.size) {
			backgroundImageView.contentMode = .scaleToFill
			backgroundImageView.image = imageScaled
		}
		
		if let titleBackgroundColor = selectedTag?.backgroundColorTitle {
			titleBackground.isHidden = false
			titleBackground.backgroundColor = titleBackgroundColor
		} else {
			titleBackground.isHidden = true
		}
		
		if let backgroundColor = selectedTag?.sheetBackgroundColor {
			self.sheetBackground.backgroundColor = backgroundColor
		}

	}

}