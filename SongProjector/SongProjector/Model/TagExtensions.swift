//
//  TagExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

extension Tag {
	
	
	var textColorTitle: UIColor? {
		get {
			guard let hex = titleTextColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleTextColorHex = newColor.toHex
			}
		}
	}
	
	var borderColorTitle: UIColor? {
		get {
			guard let hex = titleBorderColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleBorderColorHex = newColor.toHex
			}
		}
	}
	
	var textColorLyrics: UIColor? {
		get {
			guard let hex = lyricsTextColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleTextColorHex = newColor.toHex
			}
		}
	}
	
	var borderColorLyrics: UIColor? {
		get {
			guard let hex = lyricsBorderColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleBorderColorHex = newColor.toHex
			}
		}
	}
	
	func getTitleAttributes() -> [NSAttributedStringKey: Any] {
		var attributes : [NSAttributedStringKey: Any] = [:]
		if let fontFamily = self.titleFontName {
			var font = UIFont(name: fontFamily, size: CGFloat(self.titleTextSize))
			if self.isTitleBold {
				font = font?.setBoldFnc()
			}
			if self.isTitleItalian {
				font = font?.setItalicFnc()
			}
			attributes[.font] = font
		}
		
		attributes[.strokeWidth] = Int(self.titleBorderSize)
		
		if let textColor = self.textColorTitle {
			attributes[.foregroundColor] = textColor
		} else {
			attributes[.foregroundColor] = UIColor.black
		}
		
		if let borderColor = self.titleBorderColorHex {
			attributes[.strokeColor] = borderColor
		}
		
		if self.isTitleUnderlined {
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
		}
		return attributes
	}
	
	func getLyricsAttributes() -> [NSAttributedStringKey: Any] {
		var attributes : [NSAttributedStringKey: Any] = [:]
		if let fontFamily = self.lyricsFontName {
			var font = UIFont(name: fontFamily, size: CGFloat(self.lyricsTextSize))
			if self.isLyricsBold {
				font = font?.setBoldFnc()
			}
			if self.isLyricsItalian {
				font = font?.setItalicFnc()
			}
			attributes[.font] = font
		}
		
		attributes[.strokeWidth] = Int(self.lyricsBorderSize)
		
		if let textColor = self.textColorLyrics {
			attributes[.foregroundColor] = textColor
		} else {
			attributes[.foregroundColor] = UIColor.black
		}
		
		if let borderColor = self.lyricsBorderColorHex {
			attributes[.strokeColor] = borderColor
		}
		
		if self.isLyricsUnderlined {
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
		}
		return attributes
	}
}
