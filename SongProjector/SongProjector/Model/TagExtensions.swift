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
			if let newValue = newValue, let data = UIImageJPEGRepresentation(newValue, 1.0), let resizedImage = newValue.resized(toWidth: 500), let dataResized = UIImageJPEGRepresentation(resizedImage, 0.5) {
				if let path = self.imagePath {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
						self.imagePath = nil
					} catch let error as NSError {
						print("Error: \(error.domain)")
					}
				}
				
				if let path = self.imagePathThumbnail {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
					} catch let error as NSError {
						print("Error: \(error.domain)")
					}
				}
				
				
				
				
				let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let imagePath = UUID().uuidString + ".jpg"
				let imagePathThumbnail = UUID().uuidString + "thumb.jpg"

				let filename = documentsDirectory.appendingPathComponent(imagePath)
				let filenameThumb = documentsDirectory.appendingPathComponent(imagePathThumbnail)

				try? data.write(to: filename)
				try? dataResized.write(to: filenameThumb)
				self.imagePath = imagePath
				self.imagePathThumbnail = imagePathThumbnail

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

struct TagTemp {
	var title: String?
	var allHaveTitle: Bool
	var hasEmptySheet: Bool
	var backgroundColor: UIColor?
	var backgroundTransparancy: Float
	var displayTime: Bool
	
	var titleFontFamily: String
	var titleFontSize: Float
	var titleBackgroundColor: UIColor?
	var titleAlignment: String?
	var titleBorderSize: Int
	var titleBorderColor: UIColor?
	var titleTextColor: UIColor?
	var titleIsBold: Bool
	var titleIsItalian: Bool
	var titleIsUnderLined: Bool
	
	var lyricsFontFamily: String
	var lyricsFontSize: Float
	var lyricsBackgroundColor: UIColor?
	var lyricsAlignment: String?
	var lyricsBorderSize: Int
	var lyricsBorderColor: UIColor?
	var lyricsTextColor: UIColor?
	var lyricsIsBold: Bool
	var lyricsIsItalian: Bool
	var lyricsIsUnderLined: Bool
	
	var backgroundImage: UIImage?
	var backgroundImagePath: String?
	var backgroundThumb: UIImage?
	var backgroundThumbPath: String?
	
	init(tag: Tag) {
		title = tag.title
		allHaveTitle = tag.allHaveTitle
		hasEmptySheet = tag.hasEmptySheet
		if let color = tag.backgroundColor {
			backgroundColor = UIColor(hex: color)
		}
		backgroundTransparancy = tag.backgroundTransparency
		displayTime = tag.displayTime
		
		titleFontFamily = tag.titleFontName ?? "Avenir"
		titleFontSize = tag.titleTextSize
		if let color = tag.titleBackgroundColor {
			titleBackgroundColor = UIColor(hex: color)
		}
		titleAlignment = tag.titleAlignment
		titleBorderSize = Int(tag.titleBorderSize)
		if let color = tag.titleBorderColorHex {
			titleBorderColor = UIColor(hex: color)
		}
		if let color = tag.titleTextColorHex {
			titleTextColor = UIColor(hex: color)
		}
		titleIsBold = tag.isTitleBold
		titleIsItalian = tag.isTitleItalian
		titleIsUnderLined = tag.isTitleUnderlined
		
		lyricsFontFamily = tag.lyricsFontName ?? "Avenir"
		lyricsFontSize = tag.lyricsTextSize
		lyricsAlignment = tag.lyricsAlignment
		lyricsBorderSize = Int(tag.lyricsBorderSize)
		if let color = tag.lyricsBorderColorHex {
			lyricsBorderColor = UIColor(hex: color)
		}
		if let color = tag.lyricsTextColorHex {
			lyricsTextColor = UIColor(hex: color)
		}
		lyricsIsBold = tag.isLyricsBold
		lyricsIsItalian = tag.isLyricsItalian
		lyricsIsUnderLined = tag.isLyricsUnderlined
		
		backgroundImage = tag.backgroundImage
		backgroundImagePath = tag.imagePath
		backgroundThumb = tag.thumbnail
		backgroundThumbPath = tag.imagePathThumbnail
		
	}
}
