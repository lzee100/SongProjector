//
//  SheetSplit.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetSplit: SheetView {
	
	@IBOutlet var sheetBackgroundView: UIView!
	@IBOutlet var sheetBackgroundImageView: UIImageView!
	
	@IBOutlet var sheetView: UIView!
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var titleBackgroundView: UIView!
	
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var textViewLeft: UITextView!
	@IBOutlet var textViewRight: UITextView!
	
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	@IBOutlet var titleBottomConstraint: NSLayoutConstraint!
	
	private var sheet: SheetSplitEntity?
	private var selectedTag: Tag?
	private var zeroHeightConstraint: NSLayoutConstraint?
	private var newTitleBottomConstraint: NSLayoutConstraint?
	var position = 0
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetSplit", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	static func createWith(frame: CGRect, sheet: SheetSplitEntity, tag: Tag?, scaleFactor: CGFloat = 1) -> SheetSplit {
		
		let view = SheetSplit(frame: frame)
		view.sheet = sheet
		view.position = Int(sheet.position)
		view.selectedTag = tag
		view.scaleFactor = scaleFactor
		view.update()
		return view
	}
	
	
	override func update() {
		
		if let scaleFactor = scaleFactor {
			titleHeightConstraint.constant = titleHeightConstraint.constant * scaleFactor
			
			
			if let songTitle = sheet?.title {
				if let tag = selectedTag {
					if !tag.allHaveTitle && (sheet?.position ?? 0 > 0) {
						
						// set height constraint to zero
						titleHeightConstraint.isActive = false
						zeroHeightConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
						descriptionTitle.addConstraint(zeroHeightConstraint!)
						
//
//						// set title.bottom - stackView.top constraint to zero
//						titleBottomConstraint.isActive = false
//						newTitleBottomConstraint = NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: descriptionTitle, attribute: .bottom, multiplier: 1, constant: 0)
//						descriptionTitle.addConstraint(newTitleBottomConstraint!)
						
					} else {
						// remove previous height constraint
						if let zeroHeightConstraint = zeroHeightConstraint {
							descriptionTitle.removeConstraint(zeroHeightConstraint)
						}
						if let newTitleBottomConstraint = newTitleBottomConstraint {
							descriptionTitle.removeConstraint(newTitleBottomConstraint)
						}
						
						// reset height constraint
						titleHeightConstraint.isActive = true
						titleBottomConstraint.isActive = true
						
					}
					descriptionTitle.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes(scaleFactor))
				} else {
					descriptionTitle.text = songTitle
				}
			} else {
				// set height constraint to zero
				titleHeightConstraint.isActive = false
				zeroHeightConstraint = NSLayoutConstraint(item: descriptionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
				descriptionTitle.addConstraint(zeroHeightConstraint!)
				
//				// set title.bottom - stackView.top constraint to zero
//				titleBottomConstraint.isActive = false
//				newTitleBottomConstraint = NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: descriptionTitle, attribute: .bottom, multiplier: 1, constant: 0)
//				descriptionTitle.addConstraint(newTitleBottomConstraint!)
				
			}
			
			if let lyrics = sheet?.textLeft {
				if let tag = selectedTag {
					textViewLeft.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
				} else {
					textViewLeft.text = lyrics
				}
			}
			
			if let lyrics = sheet?.textRight {
				if let tag = selectedTag {
					textViewRight.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes(scaleFactor))
				} else {
					textViewRight.text = lyrics
				}
			}
			
			if let backgroundImage = selectedTag?.backgroundImage, let imageScaled = UIImage.scaleImageToSize(image: backgroundImage, size: bounds.size) {
				imageScaled.draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
				self.sheetBackgroundImageView.isHidden = false
				self.sheetBackgroundImageView.contentMode = .scaleAspectFit
				self.sheetBackgroundImageView.image = imageScaled
			} else {
				 sheetBackgroundImageView.isHidden = true
			}
			
			if let titleBackgroundColor = selectedTag?.backgroundColorTitle, let title = selectedTag?.title, title != "" {
				if let allHaveTitle = selectedTag?.allHaveTitle, allHaveTitle == false && position < 1 {
					titleBackgroundView.isHidden = false
					titleBackgroundView.backgroundColor = titleBackgroundColor
				} else if  let allHaveTitle = selectedTag?.allHaveTitle, allHaveTitle == true {
					titleBackgroundView.isHidden = false
					titleBackgroundView.backgroundColor = titleBackgroundColor
				} else {
					titleBackgroundView.isHidden = true
				}
			} else {
				titleBackgroundView.isHidden = true
			}
			
			if let backgroundColor = selectedTag?.sheetBackgroundColor, selectedTag?.backgroundImage == nil {
				self.sheetBackgroundView.backgroundColor = backgroundColor
			} else {
				self.sheetBackgroundView.backgroundColor = .white
			}
		}
	}
	
	
	
	
	
	
	
	
}
