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
	
	var backgroundColorTitle: UIColor? {
		get {
			guard let hex = titleBackgroundColor else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleBackgroundColor = newColor.toHex
			}
		}
	}
	
	var sheetBackgroundColor: UIColor? {
		get {
			guard let hex = backgroundColor else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				backgroundColor = newColor.toHex
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
				lyricsTextColorHex = newColor.toHex
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
				lyricsBorderColorHex = newColor.toHex
			}
		}
	}
	
	var backgroundImage: UIImage? {
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
			if let newValue = newValue {
				if let data = UIImageJPEGRepresentation(newValue, 1.0) {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let imagePath = UUID().uuidString + ".jpg"
					let filename = documentsDirectory.appendingPathComponent(imagePath)
					try? data.write(to: filename)
					self.imagePath = imagePath
					thumbnail = newValue.resizeImage(UIScreen.main.bounds.width, opaque: false)
				}
			} else {
				thumbnail = nil
			}
		}
	}
	
	private(set) var thumbnail: UIImage? {
		get {
			if let imagePath = imagePathThumbnail {
				let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let filePath = documentsDirectory.appendingPathComponent(imagePath).path
				return UIImage(contentsOfFile: filePath)
			} else {
				return nil
			}
		}
		set {
			if let path = imagePathThumbnail {
				let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let url = documentsDirectory.appendingPathComponent(path)
				do {
					try FileManager.default.removeItem(at: url)
					imagePathThumbnail = nil
				} catch let error as NSError {
					print("Error: \(error.domain)")
				}
			}
			if let newValue = newValue {
				if let data = UIImageJPEGRepresentation(newValue, 0.5) {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let imagePathThumbnail = UUID().uuidString + "thumb.jpg"
					let filename = documentsDirectory.appendingPathComponent(imagePathThumbnail)
					try? data.write(to: filename)
					self.imagePathThumbnail = imagePathThumbnail
				}
			}
		}
	}
	
	func getTitleAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedStringKey: Any] {
		var attributes : [NSAttributedStringKey: Any] = [:]
		if let fontFamily = self.titleFontName {
			var font = UIFont(name: fontFamily, size: (CGFloat(self.titleTextSize) * scaleFactor))
			if self.isTitleBold {
				font = font?.setBoldFnc()
			}
			if self.isTitleItalian {
				font = font?.setItalicFnc()
			}
			attributes[.font] = font
		}
		
		if let titleAlignment = titleAlignment {
			
			let paragraph = NSMutableParagraphStyle()
			
			switch titleAlignment {
			case Text.NewTag.alignLeft:
				paragraph.alignment = .left
				attributes[.paragraphStyle] = paragraph
			case Text.NewTag.alignCenter:
				paragraph.alignment = .center
				attributes[.paragraphStyle] = paragraph
			case Text.NewTag.alignRight:
				paragraph.alignment = .right
				attributes[.paragraphStyle] = paragraph
			default:
				break
			}
		}
		
		attributes[.strokeWidth] = Int(self.titleBorderSize)
		
		if let textColor = self.textColorTitle {
			attributes[.foregroundColor] = textColor
		} else {
			attributes[.foregroundColor] = UIColor.black
		}
		
		if let borderColor = self.borderColorTitle {
			attributes[.strokeColor] = borderColor
		}
		
		if self.isTitleUnderlined {
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
		}
		
		
		
		return attributes
	}
	
	func getLyricsAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedStringKey: Any] {
		var attributes : [NSAttributedStringKey: Any] = [:]
		if let fontFamily = self.lyricsFontName {
			var font = UIFont(name: fontFamily, size: (CGFloat(self.lyricsTextSize) * scaleFactor))
			if self.isLyricsBold {
				font = font?.setBoldFnc()
			}
			if self.isLyricsItalian {
				font = font?.setItalicFnc()
			}
			attributes[.font] = font
		}
		
		if let lyricsAlignment = lyricsAlignment {
			
			let paragraph = NSMutableParagraphStyle()
			
			switch lyricsAlignment {
			case Text.NewTag.alignLeft:
				paragraph.alignment = .left
				attributes[.paragraphStyle] = paragraph
			case Text.NewTag.alignCenter:
				paragraph.alignment = .center
				attributes[.paragraphStyle] = paragraph
			case Text.NewTag.alignRight:
				paragraph.alignment = .right
				attributes[.paragraphStyle] = paragraph
			default:
				break
			}
		}

		attributes[.strokeWidth] = Int(self.lyricsBorderSize)
		
		if let textColor = self.textColorLyrics {
			attributes[.foregroundColor] = textColor
		} else {
			attributes[.foregroundColor] = UIColor.black
		}
		
		if let borderColor = self.borderColorLyrics {
			attributes[.strokeColor] = borderColor
		}
		
		if self.isLyricsUnderlined {
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
		}
		return attributes
	}
	
	var backgroundTransparency: Float {
		get { return Float(backgroundTransparencyNumber) }
		set { backgroundTransparencyNumber = newValue / 100 }
	}
	
	@objc override public func delete() {
		backgroundImage = nil
		super.delete()
	}
}
