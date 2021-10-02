//
//  SheetPastorsExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-07-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension VSheetPastors {
	
    func set(image: UIImage?, imageName: String?) throws {
		let savedImage = try UIImage.set(image: image, imageName: imageName ?? imagePath, thumbNailName: thumbnailPath)
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

extension SheetPastorsEntity {
	
	func set(image: UIImage?) throws {
		let savedImage = try UIImage.set(image: image, imageName: imagePath, thumbNailName: thumbnailPath)
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
	
	override public func delete(_ save: Bool = true, context: NSManagedObjectContext, completion: ((Error?) -> Void)) {
		do {
			try set(image: nil)
			super.delete(save, context: context, completion: completion)
		} catch {
			completion(error)
		}
	}
	
}
