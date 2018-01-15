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
	
	// EXTERNAl DISPLAY
	public func toExternalDisplay() {
		
		if let externalDisplay = externalDisplayWindow {
			
			externalDisplay.addSubview(self)
			
		}
	}
	
}
