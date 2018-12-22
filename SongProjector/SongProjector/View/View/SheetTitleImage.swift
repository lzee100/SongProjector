//
//  SheetTitleImage.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetTitleImage: SheetView {
	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var descriptionContent: UILabel!
	@IBOutlet var image: UIImageView!
	@IBOutlet var imageWithBorder: UIImageView!
	@IBOutlet var titleBackground: UIView!
	@IBOutlet var backgroundImage: UIImageView!
	@IBOutlet var sheetBackgroundView: UIView!
	
	@IBOutlet var titleHightConstraint: NSLayoutConstraint!
	@IBOutlet var contentHeightConstraint: NSLayoutConstraint!
	@IBOutlet var sheetView: UIView!
	
	
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
	@IBOutlet var titleRightconstraint: NSLayoutConstraint!
	@IBOutlet var titleBottomConstraint: NSLayoutConstraint!
	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	
	@IBOutlet var imageWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet var containerLeftConstraint: NSLayoutConstraint!
	@IBOutlet var containerRightConstraint: NSLayoutConstraint!
	@IBOutlet var containerBottomConstraint: NSLayoutConstraint!
	
	
	private var zeroHeightConstraint: NSLayoutConstraint?
	private var newTitleHeightConstraint: NSLayoutConstraint?
	private var titleContentConstraint: NSLayoutConstraint?
	private var newContentHeightConstraint: NSLayoutConstraint?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetTitleImage", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	override func layoutSubviews() {
		if let scaleFactor = scaleFactor {
			
//			titleHightConstraint.constant = titleHightConstraint.constant * scaleFactor
			contentHeightConstraint.constant = contentHeightConstraint.constant * scaleFactor
			titleTopConstraint.constant = titleTopConstraint.constant * scaleFactor
			titleRightconstraint.constant = titleRightconstraint.constant * scaleFactor
			titleBottomConstraint.constant = titleBottomConstraint.constant * scaleFactor
			titleLeftConstraint.constant = titleLeftConstraint.constant * scaleFactor
			imageWidthConstraint.constant = (frame.height * 0.45)
			
			containerLeftConstraint.constant = containerLeftConstraint.constant * scaleFactor
			containerRightConstraint.constant = containerRightConstraint.constant * scaleFactor
			containerBottomConstraint.constant = containerBottomConstraint.constant * scaleFactor
		}
	}
	
	override func update() {
		
		imageWidthConstraint.constant = (frame.height * 0.4)
		timeLabel.text = ""
		
		if let sheet = sheet as? SheetTitleImageEntity {
			if sheet.content == nil || sheet.content == "" {
				
				contentHeightConstraint.isActive = false
				
				newContentHeightConstraint = NSLayoutConstraint(item: descriptionContent, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
				
				descriptionContent.addConstraint(newContentHeightConstraint!)
				
			} else {
				
				if let newContentHeightConstraint = newContentHeightConstraint {
					descriptionContent.removeConstraint(newContentHeightConstraint)
				}
				contentHeightConstraint.isActive = true
			}
			
			self.updateSheetImage()
		}
		
		updateTitle()
		updateContent()
		updateBackgroundImage()
		updateBackgroundColor()
		updateOpacity()
	}
	
	override func updateTitle() {
		let sheet = self.sheet as! SheetTitleImageEntity
		if let songTitle = sheet.title {
			if let tag = sheetTag {
				if !tag.allHaveTitle && (sheet.position > 0) {
					
					// set height constraint to zero
					titleHightConstraint.isActive = false
					zeroHeightConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
					descriptionTitle.addConstraint(zeroHeightConstraint!)
					
				} else {
					// remove previous height constraint
					if let zeroHeightConstraint = zeroHeightConstraint {
						descriptionTitle.removeConstraint(zeroHeightConstraint)
					}
					
					// reset height constraint
					titleHightConstraint.isActive = true
					
					// remove previous title - content constraint
					if let titleContentConstraint = titleContentConstraint {
						descriptionTitle.removeConstraint(titleContentConstraint)
					}
					
					// activate original contraint
					titleBottomConstraint.isActive = true
				}
				descriptionTitle.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes(scaleFactor ?? 0))
			} else {
				descriptionTitle.text = songTitle
			}
		} else {
			// set height constraint to zero
			titleHightConstraint.isActive = false
			zeroHeightConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
			descriptionTitle.addConstraint(zeroHeightConstraint!)
			
		}
		self.setNeedsLayout()
	}
	
	override func updateContent() {
		let sheet = self.sheet as! SheetTitleImageEntity
		if let tag = sheetTag, let string = sheet.content {
//			if string == "" {
//				titleContentConstraint?.isActive = false
//				titleContentConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .bottom, relatedBy: .equal, toItem: descriptionContent, attribute: .bottom, multiplier: 1, constant: 0)
//			} else {
//				// remove previous title - content constraint
//				if let titleContentConstraint = titleContentConstraint {
//					descriptionTitle.removeConstraint(titleContentConstraint)
//				}
//
//				// activate original contraint
//				titleBottomConstraint.isActive = true
//			}
			descriptionContent.attributedText = NSAttributedString(string: string, attributes: tag.getLyricsAttributes(scaleFactor ?? 1))
		} else {
			descriptionContent.text = sheet.content
		}
	}
	
	override func updateOpacity() {
		if let alpha = sheetTag?.backgroundTransparency {
			sheetBackgroundView.backgroundColor = .black
			sheetBackgroundView.alpha = CGFloat(alpha)
		}
	}
	
	override func updateBackgroundImage() {
		let image = isForExternalDispay ? sheetTag?.backgroundImage : sheetTag?.thumbnail

		if let image = image, !(sheetTag?.isBackgroundImageDeleted ?? true) {
			backgroundImage.isHidden = false
			backgroundImage.contentMode = .scaleAspectFill
			backgroundImage.image = image
			if let backgroundTransparency = sheetTag?.backgroundTransparency {
				backgroundImage.alpha = CGFloat(backgroundTransparency)
			}
		} else {
			backgroundImage.isHidden = true
		}
	}
	
	override func updateBackgroundColor() {
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
		
		if let backgroundColor = sheetTag?.sheetBackgroundColor {
			self.sheetBackgroundView.backgroundColor = backgroundColor
		} else {
			self.sheetBackgroundView.backgroundColor = .white
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
	
	override func updateSheetImage() {
		let sheet = self.sheet as! SheetTitleImageEntity
		let image = isForExternalDispay ? sheet.image : sheet.thumbnail
		
		if sheet.imageHasBorder {
			self.image.isHidden = true
			imageWithBorder.isHidden = false
			imageWithBorder.layer.borderWidth = CGFloat(CGFloat(sheet.imageBorderSize) * scaleFactor!)
			if let borderColor = sheet.imageBorderColor {
				imageWithBorder.layer.borderColor = UIColor(hex: borderColor)?.cgColor
			}
			imageWithBorder.image = image
			imageWithBorder.contentMode = .scaleAspectFill
			imageWithBorder.clipsToBounds = true
		} else {
			self.image.isHidden = false
			imageWithBorder.isHidden = true
			self.image.contentMode = UIViewContentMode(rawValue: Int(sheet.imageContentMode))!
			self.image.image = image
			self.image.contentMode = .scaleAspectFill
			self.image.clipsToBounds = true

		}
	}
	
}
