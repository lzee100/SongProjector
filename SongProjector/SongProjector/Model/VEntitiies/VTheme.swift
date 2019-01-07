//
//  VTheme.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit


class VTheme: NSObject, Codable, NSCopying {
	
	static func getThemes(getHidden: Bool = false) -> [VTheme] {
		CoreTheme.predicates.append("isHidden", notEquals: !getHidden)
		return CoreTheme.getEntities().map({ VTheme.convert($0) })
	}
	
	static func getTheme(id: Int64) -> VTheme? {
		CoreTheme.predicates.append("id", equals: id)
		if let entity = CoreTheme.getEntities().first {
			return convert(entity)
		}
		return nil
	}
	
	
	public var id: Int64 = 0
	public var title: String? = ""
	public var createdAt: Date = Date()
	public var updatedAt: Date = Date()
	public var deletedAt: Date? = nil
	
	public var allHaveTitle: Bool = false
	public var backgroundColor: String? = "FFFFFF"
	public var backgroundTransparency: Float = 0.0
	public var displayTime: Bool = false
	public var hasEmptySheet: Bool = false
	public var imagePath: String? = nil
	public var imagePathThumbnail: String? = nil
	public var isBackgroundImageDeleted: Bool = false
	public var isEmptySheetFirst: Bool = false
	public var isHidden: Bool = false
	public var isLyricsBold: Bool = false
	public var isLyricsItalian: Bool = false
	public var isLyricsUnderlined: Bool = false
	public var isTitleBold: Bool = false
	public var isTitleItalian: Bool = false
	public var isTitleUnderlined: Bool = false
	public var lyricsAlignment: Int16 = 0
	public var lyricsBorderColorHex: String? = nil
	public var lyricsBorderSize: Float = 0
	public var lyricsFontName: String? = nil
	public var lyricsTextColorHex: String? = nil
	public var lyricsTextSize: Float = 14.0
	public var position: Int16 = 0
	public var titleAlignment: Int16 = 0
	public var titleBackgroundColor: String? = nil
	public var titleBorderColorHex: String? = nil
	public var titleBorderSize: Float = 0
	public var titleFontName: String? = nil
	public var titleTextColorHex: String? = nil
	public var titleTextSize: Float = 14
	public var hasClusters: [VCluster] = []
	public var hasSheets: [VSheet] = []
	
	
	var trans: Text.Actions.Type {
		return Text.Actions.self
	}
	
	
	enum CodingKeys:String,CodingKey
	{
		case id
		case title
		case createdAt
		case updatedAt
		case deletedAt
		case allHaveTitle
		case backgroundColor
		case backgroundTransparency
		case displayTime
		case hasEmptySheet
		case imagePath
		case imagePathThumbnail
		case isBackgroundImageDeleted
		case isEmptySheetFirst
		case isHidden
		case isLyricsBold
		case isLyricsItalian
		case isLyricsUnderlined
		case isTitleBold
		case isTitleItalian
		case isTitleUnderlined
		case lyricsAlignment
		case lyricsBorderColorHex
		case lyricsBorderSize
		case lyricsFontName
		case lyricsTextColorHex
		case lyricsTextSize
		case position
		case titleAlignment
		case titleBackgroundColor
		case titleBorderColorHex
		case titleBorderSize
		case titleFontName
		case titleTextColorHex
		case titleTextSize
	}
	
	static func convert(_ theme: Theme) -> VTheme {
		let vTheme = VTheme()
		vTheme.id = theme.id
		vTheme.title = theme.title
		vTheme.createdAt = theme.createdAt ?? Date()
		vTheme.updatedAt = theme.updatedAt ?? Date()
		vTheme.deletedAt = theme.deletedAt
		vTheme.title = theme.title
		vTheme.allHaveTitle = theme.allHaveTitle
		vTheme.backgroundColor = theme.backgroundColor
		vTheme.backgroundTransparency = theme.backgroundTransparency
		vTheme.displayTime = theme.displayTime
		vTheme.hasEmptySheet = theme.hasEmptySheet
		vTheme.imagePath = theme.imagePath
		vTheme.imagePathThumbnail = theme.imagePathThumbnail
		vTheme.isBackgroundImageDeleted = theme.isBackgroundImageDeleted
		vTheme.isEmptySheetFirst = theme.isEmptySheetFirst
		vTheme.isHidden = theme.isHidden
		vTheme.isLyricsBold = theme.isLyricsBold
		vTheme.isLyricsItalian = theme.isLyricsItalian
		vTheme.isLyricsUnderlined = theme.isLyricsUnderlined
		vTheme.isTitleBold = theme.isTitleBold
		vTheme.isTitleItalian = theme.isTitleItalian
		vTheme.isTitleUnderlined = theme.isTitleUnderlined
		vTheme.lyricsAlignment = Int16(theme.lyricsAlignmentNumber)
		vTheme.lyricsBorderColorHex = theme.lyricsBorderColorHex
		vTheme.lyricsBorderSize = theme.lyricsBorderSize
		vTheme.lyricsFontName = theme.lyricsFontName
		vTheme.lyricsTextColorHex = theme.lyricsTextColorHex
		vTheme.lyricsTextSize = theme.lyricsTextSize
		vTheme.position = theme.position
		vTheme.titleAlignment = Int16(theme.titleAlignmentNumber)
		vTheme.titleBackgroundColor = theme.titleBackgroundColor
		vTheme.titleBorderColorHex = theme.titleBorderColorHex
		vTheme.titleBorderSize = theme.titleBorderSize
		vTheme.titleFontName = theme.titleFontName
		vTheme.titleTextColorHex = theme.titleTextColorHex
		vTheme.titleTextSize = theme.titleTextSize
		return vTheme
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		let vTheme = VTheme()
		vTheme.id = id
		vTheme.title = title
		vTheme.createdAt = createdAt
		vTheme.updatedAt = updatedAt
		vTheme.deletedAt = deletedAt
		vTheme.title = title
		vTheme.allHaveTitle = allHaveTitle
		vTheme.backgroundColor = backgroundColor
		vTheme.backgroundTransparency = backgroundTransparency
		vTheme.displayTime = displayTime
		vTheme.hasEmptySheet = hasEmptySheet
		vTheme.imagePath = imagePath
		vTheme.imagePathThumbnail = imagePathThumbnail
		vTheme.isBackgroundImageDeleted = isBackgroundImageDeleted
		vTheme.isEmptySheetFirst = isEmptySheetFirst
		vTheme.isHidden = isHidden
		vTheme.isLyricsBold = isLyricsBold
		vTheme.isLyricsItalian = isLyricsItalian
		vTheme.isLyricsUnderlined = isLyricsUnderlined
		vTheme.isTitleBold = isTitleBold
		vTheme.isTitleItalian = isTitleItalian
		vTheme.isTitleUnderlined = isTitleUnderlined
		vTheme.lyricsAlignment = lyricsAlignment
		vTheme.lyricsBorderColorHex = lyricsBorderColorHex
		vTheme.lyricsBorderSize = lyricsBorderSize
		vTheme.lyricsFontName = lyricsFontName
		vTheme.lyricsTextColorHex = lyricsTextColorHex
		vTheme.lyricsTextSize = lyricsTextSize
		vTheme.position = position
		vTheme.titleAlignment = titleAlignment
		vTheme.titleBackgroundColor = titleBackgroundColor
		vTheme.titleBorderColorHex = titleBorderColorHex
		vTheme.titleBorderSize = titleBorderSize
		vTheme.titleFontName = titleFontName
		vTheme.titleTextColorHex = titleTextColorHex
		vTheme.titleTextSize = titleTextSize
		return vTheme
	}
	
	
}

extension VTheme {
	
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
			else if newValue == nil {
				if let path = self.imagePath {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
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
		
		let paragraph = NSMutableParagraphStyle()
		
		switch titleAlignment{
		case 0:
			paragraph.alignment = .left
			attributes[.paragraphStyle] = paragraph
		case 1:
			paragraph.alignment = .center
			attributes[.paragraphStyle] = paragraph
		case 2:
			paragraph.alignment = .right
			attributes[.paragraphStyle] = paragraph
		default:
			break
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
			attributes[.underlineColor] = attributes[.foregroundColor]
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
		
		let paragraph = NSMutableParagraphStyle()
		
		switch lyricsAlignment {
		case 0:
			paragraph.alignment = .left
			attributes[.paragraphStyle] = paragraph
		case 1:
			paragraph.alignment = .center
			attributes[.paragraphStyle] = paragraph
		case 2:
			paragraph.alignment = .right
			attributes[.paragraphStyle] = paragraph
		default:
			break
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
}
