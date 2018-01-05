//
//  SheetCollectionCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetCollectionCell: UICollectionViewCell {

	@IBOutlet var previewView: UIView!
	@IBOutlet var previewViewAspectRatioConstraint: NSLayoutConstraint!
	

	
	var customRatioConstraint = NSLayoutConstraint()
	
	func setPreviewViewAspectRatioConstraint(multiplier: CGFloat) {
		previewViewAspectRatioConstraint.isActive = false
		previewView.removeConstraint(customRatioConstraint)
		customRatioConstraint = NSLayoutConstraint(item: previewView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: previewView, attribute: NSLayoutAttribute.width, multiplier: multiplier, constant: 0)
		previewView.addConstraint(customRatioConstraint)
	}

}
