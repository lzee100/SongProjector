//
//  SheetEmpty.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetEmpty: SheetView {
	
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var backgroundView: UIView!
	@IBOutlet var sheetView: UIView!
	
	
	private var selectedTag: Tag?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetEmpty", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	static func createWith(frame: CGRect, tag: Tag?, scaleFactor: CGFloat = 1) -> SheetEmpty {
		
		let view = SheetEmpty(frame: frame)
		view.selectedTag = tag
		view.scaleFactor = scaleFactor
		
		view.update()
		
		return view
	}
	
	override func update() {

		if let backgroundImage = selectedTag?.backgroundImage, let imageScaled = UIImage.scaleImageToSize(image: backgroundImage, size: bounds.size) {
			imageScaled.draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
			self.backgroundImageView.isHidden = false
			self.backgroundImageView.contentMode = .scaleAspectFit
			self.backgroundImageView.image = imageScaled
		} else {
			backgroundImageView.isHidden = true
		}

		
		if let backgroundColor = selectedTag?.sheetBackgroundColor, selectedTag?.backgroundImage == nil {
			self.backgroundView.backgroundColor = backgroundColor
		} else {
			self.backgroundView.backgroundColor = .white
		}
	}
}
