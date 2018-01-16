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
	
	
	
	private var sheet: SheetTitleImageEntity?
	private var selectedTag: Tag?
	private var zeroHeightConstraint: NSLayoutConstraint?
	private var newTitleHeightConstraint: NSLayoutConstraint?
	private var titleContentConstraint: NSLayoutConstraint?
	private var newContentHeightConstraint: NSLayoutConstraint?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetTitleImage", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	static func createWith(frame: CGRect, sheet: SheetTitleImageEntity, tag: Tag?, scaleFactor: CGFloat = 1) -> SheetTitleImage {
		
		let view = SheetTitleImage(frame: frame)
		view.sheet = sheet
		view.selectedTag = tag
		view.imageWidthConstraint.constant = (frame.height * 0.4)
		
		if sheet.content == nil || sheet.content == "" {
			
			view.contentHeightConstraint.isActive = false
			
			view.newContentHeightConstraint = NSLayoutConstraint(item: view.descriptionContent, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
			
			view.descriptionContent.addConstraint(view.newContentHeightConstraint!)
			
		} else {
			
			if let newContentHeightConstraint = view.newContentHeightConstraint {
				view.descriptionContent.removeConstraint(newContentHeightConstraint)
			}
			view.contentHeightConstraint.isActive = true
		}
		
		if sheet.imageHasBorder {
			view.image.isHidden = true
			view.imageWithBorder.isHidden = false
			view.imageWithBorder.layer.borderWidth = CGFloat(Int(sheet.imageBorderSize))
			if let borderColor = sheet.imageBorderColor {
				view.imageWithBorder.layer.borderColor = UIColor(hex: borderColor)?.cgColor
			}
			if let image = sheet.image {
				view.imageWithBorder.image = image
			}
		} else {
			view.image.isHidden = false
			view.imageWithBorder.isHidden = true
			view.image.contentMode = UIViewContentMode(rawValue: Int(sheet.imageContentMode))!
			if let image = sheet.image {
				view.image.image = image
			}
		}
		
		view.scaleFactor = scaleFactor
		
		view.update()

		return view
	}
	
	override func update() {
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
			
			if let songTitle = sheet?.title {
				if let tag = selectedTag {
					if !tag.allHaveTitle && (sheet?.position ?? 0 > 0) {
						
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
			
			if let lyrics = sheet?.content {
				if let tag = selectedTag {
					descriptionContent.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
				} else {
					descriptionContent.text = lyrics
				}
			}
			
			if let backgroundImage = selectedTag?.backgroundImage, let imageScaled = UIImage.scaleImageToSize(image: backgroundImage, size: bounds.size) {
				imageScaled.draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
				self.backgroundImage.isHidden = false
				self.backgroundImage.contentMode = .scaleAspectFit
				self.backgroundImage.image = imageScaled
			} else {
				backgroundImage.isHidden = true
			}
			
			if let titleBackgroundColor = selectedTag?.backgroundColorTitle {
				titleBackground.isHidden = false
				titleBackground.backgroundColor = titleBackgroundColor
			} else {
				titleBackground.isHidden = true
			}
			
			if let backgroundColor = selectedTag?.sheetBackgroundColor, selectedTag?.backgroundImage == nil {
				self.sheetBackgroundView.backgroundColor = backgroundColor
			} else {
				self.sheetBackgroundView.backgroundColor = .white
			}
		}
	}
}
