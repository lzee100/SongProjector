//
//  SheetTitleImageExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit


extension VSheetTitleImage {
	
	func set(image: UIImage?) throws {
		let savedImage = try UIImage.set(image: image, imagePath: self.imagePath, thumbnailPath: self.thumbnailPath)
		self.imagePath = savedImage.imagePath
		self.thumbnailPath = savedImage.thumbPath
	}
	
	private(set) var image: UIImage? {
		get {
			return UIImage.get(imagePath: imagePath)
		}
		set {
		}
	}
	
	private(set) var thumbnail: UIImage? {
		get {
			return UIImage.get(imagePath: thumbnailPath)
		}
		set {
		}
	}
	
}

extension SheetTitleImageEntity {
	
	func set(image: UIImage?) throws {
		let savedImage = try UIImage.set(image: image, imagePath: self.imagePath, thumbnailPath: self.thumbnailPath)
		self.imagePath = savedImage.imagePath
		self.thumbnailPath = savedImage.thumbPath
	}
	
	private(set) var image: UIImage? {
		get {
			UIImage.get(imagePath: self.imagePath)
		}
		set {
		}
	}
	
	override public func delete(_ save: Bool = true, isBackground: Bool, completion: ((Error?) -> Void)) {
		do {
			try set(image: nil)
			super.delete(save, isBackground: isBackground, completion: completion)
		} catch {
			completion(error)
		}
	}
	
}
