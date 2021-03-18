//
//  UIColorExtension.swift
//  SongViewer
//
//  Created by Leo van der Zee on 04-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {


	
	static let primary = UIColor.blue
	static let lightGrey = UIColor.lightGray
	static let primaryTextColor = UIColor.blackColor
	
	static let errorColor = UIColor.red
	static let barColor = UIColor.darkGray
	static let bulletColor = UIColor.red
	static let seperatorColor = UIColor.lightGray
	static let placeholderColor = UIColor.init(red: 150, green: 150, blue: 150, alpha: 1)
	
	static let textColorNormal = UIColor.whiteColor
	
}


extension UIColor {
	
		// MARK: - Initialization
		
		convenience init?(hex: String) {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }

            if ((cString.count) != 6) {
                return nil
            }

            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
            
//			var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//			hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")
//
//			// Helpers
//			var rgb: UInt32 = 0
//			var r: CGFloat = 0.0
//			var g: CGFloat = 0.0
//			var b: CGFloat = 0.0
//			var a: CGFloat = 1.0
//			let length = hexNormalized.count
//
//			// Create Scanner
//			Scanner(string: hexNormalized).scanHexInt32(&rgb)
//
//			if length == 6 {
//				r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//				g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//				b = CGFloat(rgb & 0x0000FF) / 255.0
//
//			} else if length == 8 {
//				r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
//				g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
//				b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
//				a = CGFloat(rgb & 0x000000FF) / 255.0
//
//			} else {
//				return nil
//			}
//
//			self.init(red: r, green: g, blue: b, alpha: a)
		}
	
	// MARK: - Convenience Methods
	
//	var hexCode: String? {
//		// Extract Components
//		guard let components = cgColor.components, components.count >= 3 else {
//			return nil
//		}
//
//		// Helpers
//		let r = Float(components[0])
//		let g = Float(components[1])
//		let b = Float(components[2])
//		var a = Float(1.0)
//
//		if components.count >= 4 {
//			a = Float(components[3])
//		}
//
//		// Create Hex String
//		let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
//
//		return hex
//	}
	
	var hexCode: String {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		return String(
			format: "%02X%02X%02X",
			Int(r * 0xff),
			Int(g * 0xff),
			Int(b * 0xff)
		)
	}
	
}
