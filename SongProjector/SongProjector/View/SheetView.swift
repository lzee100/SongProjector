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
	@IBOutlet var lyricsTextView: UITextView!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var topBorderConstraint: NSLayoutConstraint!
	@IBOutlet var rightBorderConstraint: NSLayoutConstraint!
	@IBOutlet var bottomBorderConstraint: NSLayoutConstraint!
	@IBOutlet var leftBorderConstraint: NSLayoutConstraint!
	
	
	
	
	var songTitle: String?
	var lyrics: String?
	var selectedTag: Tag?
	var isEmptySheet: Bool = false
	var scaleFactor: CGFloat = 1
	
	var previewTitleAttributes: [NSAttributedStringKey: Any]?
	var previewLyricsAttributes: [NSAttributedStringKey: Any]?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
//		fatalError("init(coder:) has not been implemented")
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("SheetController", owner: self, options: [:])
		addSubview(sheetView)
		sheetView.frame = bounds
	}
	
	func update() {
		
		topBorderConstraint.constant = topBorderConstraint.constant * scaleFactor
		rightBorderConstraint.constant = rightBorderConstraint.constant * scaleFactor
		bottomBorderConstraint.constant = bottomBorderConstraint.constant * scaleFactor
		leftBorderConstraint.constant = leftBorderConstraint.constant * scaleFactor

		if let songTitle = songTitle, let tag = selectedTag {
			if var previewTitleAttributes = previewTitleAttributes {
				if let font = previewTitleAttributes[.font] as? UIFont {
					previewTitleAttributes[.font] = UIFont(name: font.fontName, size: font.pointSize * scaleFactor)
				}
				titleLabel.attributedText = NSAttributedString(string: songTitle, attributes: previewTitleAttributes)
			} else {
				titleLabel.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes(scaleFactor))
			}
			
		} else if let songTitle = songTitle {
			titleLabel.text = songTitle
		}

		if let lyrics = lyrics, let tag = selectedTag {
			if var previewLyricsAttributes = previewLyricsAttributes {
				if let font = previewLyricsAttributes[.font] as? UIFont {
					previewLyricsAttributes[.font] = UIFont(name: font.fontName, size: font.pointSize * scaleFactor)
				}
				lyricsTextView.attributedText = NSAttributedString(string: lyrics, attributes: previewLyricsAttributes)
			} else {
				lyricsTextView.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
			}

			
		} else if let lyrics = lyrics {
			lyricsTextView.text = lyrics
		}

		if let backgroundImage = selectedTag?.backgroundImage, let imageScaled = UIImage.scaleImageToSize(image: backgroundImage, size: frame.size) {
			backgroundImageView.contentMode = .scaleToFill
			backgroundImageView.image = imageScaled
		}

	}

	
//     Only override draw() if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
		
    }

}
