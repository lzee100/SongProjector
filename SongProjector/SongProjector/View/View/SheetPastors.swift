//
//  SheetPastors.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-07-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetPastors: SheetView {

	@IBOutlet var sheetBackgroundImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var titleLabelTrans: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var descriptionLabelTrans: UILabel!
	@IBOutlet var titleBackground: UIView!
	@IBOutlet var titleBackgroundStart: UIView!
	@IBOutlet var titleBackgroundEnd: UIView!
	@IBOutlet var descriptionBackground: UIView!
	@IBOutlet var descriptionBackgroundStart: UIView!
	@IBOutlet var descriptionBackgroundEnd: UIView!
	
	@IBOutlet var outerBorderPicture: UIView!
	@IBOutlet var innerBorderPicture: UIView!
	@IBOutlet var imageViewPicture: UIImageView!
	
	@IBOutlet var outerBorderLeftConstraint: NSLayoutConstraint!
	@IBOutlet var outerBorderLeftConstraintTrans: NSLayoutConstraint!
	@IBOutlet var outerBorderImageWidthConstraint: NSLayoutConstraint!
	@IBOutlet var outerBorderImageWidthConstraintTrans: NSLayoutConstraint!
	
	@IBOutlet var titleBackgroundTopMarginConstraint: NSLayoutConstraint!
	@IBOutlet var titleBackgroundBottomMarginConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionBackgroundTopMarginConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionBackgroundBottomMarginConstraint: NSLayoutConstraint!
	
	
	@IBOutlet var innerBorderWidthConstraint: NSLayoutConstraint!
	@IBOutlet var imageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet var titleBackgroundStartTrailing: NSLayoutConstraint!
	@IBOutlet var descriptionBackgroundStartTrailing: NSLayoutConstraint!
	@IBOutlet var descriptionBackgroundEndLeading: NSLayoutConstraint!
	
	@IBOutlet var titleLabelMaxLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleLabelMaxRightConstraint: NSLayoutConstraint!
	@IBOutlet var titleLabelTransMaxLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleLabelTransMaxRightConstraint: NSLayoutConstraint!

	
	
	@IBOutlet var descriptionLabelMaxLeftConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionLabelMaxRightConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionLabelTransMaxLeftConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionLabelTransMaxRightConstraint: NSLayoutConstraint!

	@IBOutlet var titleBackgroundBottomConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionBackgroundTopConstraint: NSLayoutConstraint!
	@IBOutlet var titleLabelBottomConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionLabelTopConstraint: NSLayoutConstraint!
	
	@IBOutlet var sheetPastorsView: UIView!
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetPastors", owner: self, options: [:])
		sheetPastorsView.frame = self.frame
		addSubview(sheetPastorsView)
	}
	
	override func layoutSubviews() {
		setup()
	}
	
	override func update() {
		
		updateTitle()
		updateContent()
		updateBackgroundColor()
		updateBackgroundImage()
		updateSheetImage()
		updateOpacity()
		
		outerBorderLeftConstraintTrans.constant = outerBorderLeftConstraintTrans.constant * (scaleFactor ?? 1)
		outerBorderLeftConstraint.constant = outerBorderLeftConstraint.constant * (scaleFactor ?? 1)
		
		titleLabelMaxLeftConstraint.constant = titleLabelMaxLeftConstraint.constant * (scaleFactor ?? 1)
		titleLabelMaxRightConstraint.constant = titleLabelMaxRightConstraint.constant * (scaleFactor ?? 1)
		titleLabelTransMaxLeftConstraint.constant = titleLabelTransMaxLeftConstraint.constant * (scaleFactor ?? 1)
		titleLabelTransMaxRightConstraint.constant = titleLabelTransMaxRightConstraint.constant * (scaleFactor ?? 1)
		
		titleBackgroundTopMarginConstraint.constant = titleBackgroundTopMarginConstraint.constant * (scaleFactor ?? 1)
		titleBackgroundBottomMarginConstraint.constant = titleBackgroundBottomMarginConstraint.constant * (scaleFactor ?? 1)
		
		descriptionBackgroundTopMarginConstraint.constant = descriptionBackgroundTopMarginConstraint.constant * (scaleFactor ?? 1)
		descriptionBackgroundBottomMarginConstraint.constant = descriptionBackgroundBottomMarginConstraint.constant * (scaleFactor ?? 1)
		
		titleLabelBottomConstraint.constant = titleLabelBottomConstraint.constant * (scaleFactor ?? 1)
		descriptionLabelTopConstraint.constant = descriptionLabelTopConstraint.constant * (scaleFactor ?? 1)
		descriptionLabelMaxLeftConstraint.constant = descriptionLabelMaxLeftConstraint.constant * (scaleFactor ?? 1)
		descriptionLabelMaxRightConstraint.constant = descriptionLabelMaxRightConstraint.constant * (scaleFactor ?? 1)
		descriptionLabelTransMaxLeftConstraint.constant = descriptionLabelTransMaxLeftConstraint.constant * (scaleFactor ?? 1)
		descriptionLabelTransMaxRightConstraint.constant = descriptionLabelTransMaxRightConstraint.constant * (scaleFactor ?? 1)
		
		titleBackgroundBottomConstraint.constant = titleBackgroundBottomConstraint.constant * (scaleFactor ?? 1)
		descriptionBackgroundTopConstraint.constant = descriptionBackgroundTopConstraint.constant * (scaleFactor ?? 1)
		
		setup()
	}
	
	private func setup() {
		
		titleLabelTrans.alpha = 0
		descriptionLabelTrans.alpha = 0
		outerBorderImageWidthConstraint.constant = self.frame.width * 0.35
		outerBorderImageWidthConstraintTrans.constant = self.frame.width * 0.35
		imageViewWidthConstraint.constant = outerBorderImageWidthConstraintTrans.constant * ( 130 / 170 )
		
		innerBorderWidthConstraint.constant = outerBorderImageWidthConstraintTrans.constant * ( 136 / 170 )
		
		layoutIfNeeded()
		DispatchQueue.main.async {
			self.titleBackgroundStart.layer.cornerRadius = self.titleBackgroundStart.frame.height / 2
			self.titleBackgroundEnd.layer.cornerRadius = self.titleBackgroundEnd.frame.height / 2

			self.descriptionBackgroundStart.layer.cornerRadius = self.descriptionBackgroundStart.frame.height / 2
			self.descriptionBackgroundEnd.layer.cornerRadius = self.descriptionBackgroundEnd.frame.height / 2
		}
		
		outerBorderPicture.layer.cornerRadius = outerBorderPicture.frame.width / 2
		innerBorderPicture.layer.cornerRadius = innerBorderPicture.frame.width / 2
		imageViewPicture.layer.cornerRadius = imageViewPicture.frame.width / 2
		imageViewPicture.clipsToBounds = true

	}
	
	override func updateTitle() {
		let sheet = self.sheet as! SheetPastorsEntity
		if let title = sheet.title {
			if let tag = sheetTag {
				titleLabel.attributedText = NSAttributedString(string: title, attributes: tag.getTitleAttributes(scaleFactor ?? 0))
				titleLabelTrans.attributedText = NSAttributedString(string: title, attributes: tag.getTitleAttributes(scaleFactor ?? 0))
			} else {
				titleLabel.text = title
				titleLabelTrans.text = title
			}
			setup()
		}
	}
	
	override func updateContent() {
		let sheet = self.sheet as! SheetPastorsEntity
		if let content = sheet.content {
			if let tag = sheetTag {
				descriptionLabel.attributedText = NSAttributedString(string: content, attributes: tag.getTitleAttributes(scaleFactor ?? 0))
				descriptionLabelTrans.attributedText = NSAttributedString(string: content, attributes: tag.getTitleAttributes(scaleFactor ?? 0))
			} else {
				descriptionLabel.text = content
				descriptionLabelTrans.text = content
			}
		}
		let isHidden = sheet.content == nil || sheet.content == ""
		descriptionLabel.isHidden = isHidden
		descriptionBackground.isHidden = isHidden
		descriptionBackgroundEnd.isHidden = isHidden
		descriptionBackgroundStart.isHidden = isHidden
		setup()
	}
	
	override func updateBackgroundColor() {
		if let color = sheetTag?.backgroundColor {
			backgroundColor = UIColor(hex: color)
		} else {
			backgroundColor = .white
		}
	}
	
	override func updateBackgroundImage() {
		let image = isForExternalDispay ? sheetTag?.backgroundImage : sheetTag?.thumbnail
		
		if let image = image, !(sheetTag?.isBackgroundImageDeleted ?? true) {
			sheetBackgroundImageView.isHidden = false
			sheetBackgroundImageView.contentMode = .scaleAspectFill
			sheetBackgroundImageView.image = image
			if let backgroundTransparency = sheetTag?.backgroundTransparancy {
				sheetBackgroundImageView.alpha = CGFloat(backgroundTransparency)
			}
		} else {
			sheetBackgroundImageView.isHidden = true
		}
	}
	
	override func updateOpacity() {
		if let alpha = sheetTag?.backgroundTransparancy {
			backgroundColor = .black
			sheetBackgroundImageView.alpha = CGFloat(alpha)
		}
	}
	
	override func updateSheetImage() {
		if let sheet = sheet as? SheetPastorsEntity {
			imageViewPicture.image = isForExternalDispay ? sheet.image : sheet.thumbnail
		}
	}
	

}
