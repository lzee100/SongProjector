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
			
			
			if sheet.imageHasBorder {
				image.isHidden = true
				imageWithBorder.isHidden = false
				imageWithBorder.layer.borderWidth = CGFloat(CGFloat(sheet.imageBorderSize) * scaleFactor!)
				if let borderColor = sheet.imageBorderColor {
					imageWithBorder.layer.borderColor = UIColor(hex: borderColor)?.cgColor
				}
				if let image = sheet.image {
					imageWithBorder.image = image
				}
			} else {
				image.isHidden = false
				imageWithBorder.isHidden = true
				image.contentMode = UIViewContentMode(rawValue: Int(sheet.imageContentMode))!
				if let image = sheet.image {
					self.image.image = image
				}
			}
		}
		
		if let scaleFactor = scaleFactor {
						
				titleHightConstraint.constant = titleHightConstraint.constant * scaleFactor
				contentHeightConstraint.constant = contentHeightConstraint.constant * scaleFactor
				titleTopConstraint.constant = titleTopConstraint.constant * scaleFactor
				titleRightconstraint.constant = titleRightconstraint.constant * scaleFactor
				titleBottomConstraint.constant = titleBottomConstraint.constant * scaleFactor
				titleLeftConstraint.constant = titleLeftConstraint.constant * scaleFactor
				imageWidthConstraint.constant = (frame.height * 0.45)

				containerLeftConstraint.constant = containerLeftConstraint.constant * scaleFactor
				containerRightConstraint.constant = containerRightConstraint.constant * scaleFactor
				containerBottomConstraint.constant = containerBottomConstraint.constant * scaleFactor
			
			if let songTitle = sheet.title {
				if let tag = sheetTag {
					if !tag.allHaveTitle && (sheet.position > 0) {
						
						// set height constraint to zero
						titleHightConstraint.isActive = false
						zeroHeightConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
						descriptionTitle.addConstraint(zeroHeightConstraint!)
						
//						// set title - content text constraint to zero
//						titleBottomConstraint.isActive = false
//						titleContentConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .bottom, relatedBy: .equal, toItem: descriptionContent, attribute: .top, multiplier: 1, constant: 0)
//						
//						descriptionTitle.addConstraint(titleContentConstraint!)
						
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
					descriptionTitle.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes(scaleFactor))
				} else {
					descriptionTitle.text = songTitle
				}
			} else {
				// set height constraint to zero
				titleHightConstraint.isActive = false
				zeroHeightConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
				descriptionTitle.addConstraint(zeroHeightConstraint!)
				
			}
			
			if let sheet = sheet as? SheetTitleImageEntity, let lyrics = sheet.content {
				if let tag = sheetTag {
					descriptionContent.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
				} else {
					descriptionContent.text = lyrics
				}
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
			
			if let backgroundColor = sheetTag?.sheetBackgroundColor, sheetTag?.backgroundImage == nil {
				self.sheetBackgroundView.backgroundColor = backgroundColor
			} else {
				self.sheetBackgroundView.backgroundColor = .white
			}
		}
	}
	
	override func changeOpacity(newValue: Float) {
		if let _ = isForExternalDispay ? sheetTag?.backgroundImage : sheetTag?.thumbnail {
			sheetBackgroundView.alpha = CGFloat(newValue)
		}
	}
	
	
	override func setBackgroundImage(image: UIImage?) {
		if let image = image {
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
	
	func setSheetImage(_ newValue: UIImage?) {
		if let sheet = sheet as? SheetTitleImageEntity, sheet.imageHasBorder {
			if let image = newValue {
				imageWithBorder.image = image
			}
		} else if let nv = newValue {
			image.image = nv
		}
	}
	
}
