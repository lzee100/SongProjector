//
//  SheetView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetView: UIView {
	
	open var scaleFactor: CGFloat?
	public private(set) var isForExternalDispay: Bool = false
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	open func customInit() {
	}
	
	open func update() {
		
	}
	
	open func changeOpacity(newValue: Float) {

	}
	open func setBackgroundImage(image: UIImage?) {

	}
	
	open func updateTime(isOn: Bool) {

	}
	
	// EXTERNAl DISPLAY
	public func toExternalDisplay() {
		
		if let externalDisplay = externalDisplayWindow {
			
			for subview in externalDisplay.subviews {
				subview.removeFromSuperview()
			}
			
			isForExternalDispay = true
			update()
			externalDisplay.addSubview(self)
			isForExternalDispay = false
		}
	}
	
}
