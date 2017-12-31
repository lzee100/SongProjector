//
//  ImageExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	
	static func scaleImageToSize(image: UIImage, size: CGSize) -> UIImage? {
		let hasAlpha = false
		let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
		
		UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
		image.draw(in: CGRect(origin: CGPoint.zero, size: size))
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return scaledImage
	}
	
}
