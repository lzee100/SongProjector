//
//  TextViewExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		setup()
	}
    
	func setup() {
		textContainerInset = UIEdgeInsets.zero
		textContainer.lineFragmentPadding = 0
	}
    
    func noPadding() {
        textContainer.lineFragmentPadding = 0
        textContainerInset = .zero
    }
    
}
