//
//  ViewExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	
	func asImage() -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
		return renderer.image { rendererContext in
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
		}
	}
	
}
