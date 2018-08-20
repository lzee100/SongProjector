//
//  TagExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

enum TagAttribute {
	case asTag
	
	case title
	
	case allHaveTitle
	case displayTime
	case hasEmptySheet
	case isEmptySheetFirst
	case isLyricsBold
	case isLyricsItalian
	case isLyricsUnderlined
	case isTitleBold
	case isTitleItalian
	case isTitleUnderlined
	
	case backgroundColor
	case backgroundImage
	case backgroundTransparancy

	case lyricsAlignment
	case lyricsBorderColor
	case lyricsFontName
	case lyricsTextColorHex
	case lyricsTextSize
	case lyricsBorderSize
	
	case titleAlignment
	case titleBackgroundColor
	case titleBorderColorHex
	case titleFontName
	case titleTextColorHex
	case titleTextSize
	case titleBorderSize
	
	var description: String {
		switch self {
		case .asTag: return Text.NewTag.descriptionAsTag
		case .title: return Text.NewTag.descriptionTitle
		case .allHaveTitle: return Text.NewTag.descriptionAllTitle
		case .displayTime: return Text.NewTag.descriptionDisplayTime
		case .hasEmptySheet: return Text.NewTag.descriptionHasEmptySheet
		case .isEmptySheetFirst: return Text.NewTag.descriptionPositionEmptySheet
		case .isLyricsBold: return Text.NewTag.bold
		case .isLyricsItalian: return Text.NewTag.italic
		case .isLyricsUnderlined: return Text.NewTag.underlined
		case .isTitleBold: return Text.NewTag.bold
		case .isTitleItalian: return Text.NewTag.italic
		case .isTitleUnderlined: return Text.NewTag.underlined
			
		case .backgroundColor: return Text.NewTag.descriptionBackgroundColor
		case .backgroundImage: return Text.NewTag.backgroundImage
		case .backgroundTransparancy: return Text.NewTag.descriptionBackgroundTransparency
		case .lyricsAlignment: return Text.NewTag.descriptionAlignment
		case .lyricsBorderColor: return Text.NewTag.borderColor
		case .lyricsBorderSize: return Text.NewTag.borderSizeDescription
		case .lyricsFontName: return Text.NewTag.fontFamilyDescription
		case .lyricsTextColorHex: return Text.NewTag.textColor
		case .lyricsTextSize: return Text.NewTag.fontSizeDescription
			
		case .titleAlignment: return Text.NewTag.descriptionAlignment
		case .titleBackgroundColor: return Text.NewTag.descriptionBackgroundColor
		case .titleBorderColorHex: return Text.NewTag.borderColor
		case .titleTextSize: return Text.NewTag.fontSizeDescription
		case .titleFontName: return Text.NewTag.fontFamilyDescription
		case .titleTextColorHex: return Text.NewTag.textColor
		case .titleBorderSize: return Text.NewTag.borderSizeDescription
			
		}
	}
}

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

		let paragraph = NSMutableParagraphStyle()
		
		switch titleAlignmentNumber {
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
		
		switch lyricsAlignmentNumber {
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
	
	var backgroundTransparency: Float {
		get { return Float(backgroundTransparencyNumber) }
		set { backgroundTransparencyNumber = newValue / 100 }
	}
	
	@objc override public func delete() {
		backgroundImage = nil
		super.delete()
	}
	
	func getTemp() -> Tag {
		let tempTag = CoreTag.createEntity(fireNotification: false)
		tempTag.isTemp = true
		tempTag.title = title
		tempTag.allHaveTitle = allHaveTitle
		tempTag.hasEmptySheet = hasEmptySheet
		tempTag.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparency)
		tempTag.backgroundTransparency = Float(cgfloatValue) * 100
		tempTag.displayTime = displayTime
		
		tempTag.titleFontName = titleFontName ?? "Avenir"
		tempTag.titleTextSize = titleTextSize
		tempTag.titleBackgroundColor = titleBackgroundColor
		tempTag.titleAlignmentNumber = titleAlignmentNumber
		tempTag.titleBorderSize = titleBorderSize
		tempTag.titleBorderColorHex = titleBorderColorHex
		tempTag.titleTextColorHex = titleTextColorHex
		tempTag.isTitleBold = isTitleBold
		tempTag.isTitleItalian = isTitleItalian
		tempTag.isTitleUnderlined = isTitleUnderlined
		
		tempTag.lyricsFontName = lyricsFontName ?? "Avenir"
		tempTag.lyricsTextSize = lyricsTextSize
		tempTag.lyricsAlignmentNumber = lyricsAlignmentNumber
		tempTag.lyricsBorderSize = lyricsBorderSize
		tempTag.lyricsBorderColorHex = lyricsBorderColorHex
		tempTag.lyricsTextColorHex = lyricsTextColorHex
		tempTag.isLyricsBold = isLyricsBold
		tempTag.isLyricsItalian = isLyricsItalian
		tempTag.isLyricsUnderlined = isLyricsUnderlined
		
		tempTag.imagePath = imagePath
		tempTag.imagePathThumbnail = imagePathThumbnail
		tempTag.isHidden = isHidden
		return tempTag
	}
	
	func mergeSelfInto(tag: Tag, isTemp: Bool = false, sheetType: SheetType) {
		tag.isTemp = isTemp
		tag.title = title
		tag.allHaveTitle = allHaveTitle
		tag.hasEmptySheet = hasEmptySheet
		tag.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparency)
		tag.backgroundTransparency = Float(cgfloatValue) * 100
		tag.displayTime = displayTime
		
		tag.titleFontName = titleFontName ?? "Avenir"
		tag.titleTextSize = titleTextSize
		if sheetType != .SheetPastors {
			tag.titleBackgroundColor = titleBackgroundColor
			tag.titleAlignmentNumber = titleAlignmentNumber
		}
		tag.titleBorderSize = titleBorderSize
		tag.titleBorderColorHex = titleBorderColorHex
		tag.titleTextColorHex = titleTextColorHex
		tag.isTitleBold = isTitleBold
		tag.isTitleItalian = isTitleItalian
		tag.isTitleUnderlined = isTitleUnderlined
		
		tag.lyricsFontName = lyricsFontName ?? "Avenir"
		tag.lyricsTextSize = lyricsTextSize
		if sheetType != .SheetPastors {
			tag.lyricsAlignmentNumber = lyricsAlignmentNumber
		}
		tag.lyricsBorderSize = lyricsBorderSize
		tag.lyricsBorderColorHex = lyricsBorderColorHex
		tag.lyricsTextColorHex = lyricsTextColorHex
		tag.isLyricsBold = isLyricsBold
		tag.isLyricsItalian = isLyricsItalian
		tag.isLyricsUnderlined = isLyricsUnderlined
		
		tag.imagePath = imagePath
		tag.imagePathThumbnail = imagePathThumbnail
	}

}
