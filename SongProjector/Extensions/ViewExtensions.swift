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

	func copyView<T: UIView>() -> T {
		return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
	}
	
	func asImage() -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
		return renderer.image { rendererContext in
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
		}
	}
		
	public static func create<V : UIView>(nib: String) -> V? {
		
		let object : Any? = UINib(nibName: nib, bundle: nil).instantiate(withOwner: nil, options: nil).first
		
		if let object = object {
			return object as? V
		} else {
			return nil
		}
		
	}
	
}
