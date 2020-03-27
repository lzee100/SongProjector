//
//  StringExtensions.swift
//  SongViewer
//
//  Created by Leo van der Zee on 06-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation
import UIKit

extension String {
	
	var isBlanc: Bool {
		return self.trimmingCharacters(in: .whitespacesAndNewlines) == ""
	}
	
	var isLetter: Bool {
		let characterIndex = "abcdefghijklmnopqrstuvwxyz"
		if let character = self.first {
			if (characterIndex.index(of: character) == nil) {
				return false
			}
			return true
		} else {
			return false
		}
	}
	
		var isNumber: Bool {
			let characterIndex = "0123456789"
			if let character = self.first {
				if (characterIndex.index(of: character) == nil) {
					return false
				}
				return true
			} else {
				return false
			}
//			return !isEmpty
//			return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
	}
	
	func captalizeFirstCharacter() -> String {
		var result = self
		
		let substr1 = String(self[startIndex]).uppercased()
		result.replaceSubrange(...startIndex, with: substr1)
		
		return result
	}
	
	var length: Int {
		return self.count
	}
	
	subscript (i: Int) -> String {
		return self[i ..< i + 1]
	}
	
	func substring(fromIndex: Int) -> String {
		return self[min(fromIndex, length) ..< length]
	}
	
	func substring(toIndex: Int) -> String {
		return self[0 ..< max(0, toIndex)]
	}
	
	subscript (r: Range<Int>) -> String {
		let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
											upper: min(length, max(0, r.upperBound))))
		let start = index(startIndex, offsetBy: range.lowerBound)
		let end = index(start, offsetBy: range.upperBound - range.lowerBound)
		return String(self[start ..< end])
	}
	
	func deletingPrefix(_ prefix: String) -> String {
		guard self.hasPrefix(prefix) else { return self }
		return String(self.dropFirst(prefix.count))
	}
	
	func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.height)
	}
	
	func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.width)
	}
}
