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
		if let imagePath = imagePath {
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let filePath = documentsDirectory.appendingPathComponent(imagePath).path
			return UIImage(contentsOfFile: filePath)
		} else {
			return nil
		}
	}
	
}
