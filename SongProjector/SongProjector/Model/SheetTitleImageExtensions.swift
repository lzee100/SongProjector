//
//  SheetTitleImageExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit


extension SheetTitleImageEntity {
	
	var image: UIImage? {
		get {
			if let imagePath = imagePath {
				let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let filePath = documentsDirectory.appendingPathComponent(imagePath).path
				return UIImage(contentsOfFile: filePath)
			} else {
				return nil
			}
		}
		set {
			if newValue == nil {
				if let path = imagePath {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
						imagePath = nil
					} catch let error as NSError {
						print("Error: \(error.domain)")
					}
				}
			} else {
				if let data = UIImagePNGRepresentation(newValue!) {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let imagePath = String(UUID().uuidString) + ".png"
					let filename = documentsDirectory.appendingPathComponent(imagePath)
					try? data.write(to: filename)
					self.imagePath = imagePath
				}
			}
		}
	}
	
}
