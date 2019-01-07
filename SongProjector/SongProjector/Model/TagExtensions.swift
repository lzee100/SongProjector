//
//  themeExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

enum ThemeAttribute {
	case asTheme
	
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
		case .asTheme: return Text.NewTheme.descriptionAsTheme
		case .title: return Text.NewTheme.descriptionTitle
		case .allHaveTitle: return Text.NewTheme.descriptionAllTitle
		case .displayTime: return Text.NewTheme.descriptionDisplayTime
		case .hasEmptySheet: return Text.NewTheme.descriptionHasEmptySheet
		case .isEmptySheetFirst: return Text.NewTheme.descriptionPositionEmptySheet
		case .isLyricsBold: return Text.NewTheme.bold
		case .isLyricsItalian: return Text.NewTheme.italic
		case .isLyricsUnderlined: return Text.NewTheme.underlined
		case .isTitleBold: return Text.NewTheme.bold
		case .isTitleItalian: return Text.NewTheme.italic
		case .isTitleUnderlined: return Text.NewTheme.underlined
			
		case .backgroundColor: return Text.NewTheme.descriptionBackgroundColor
		case .backgroundImage: return Text.NewTheme.backgroundImage
		case .backgroundTransparancy: return Text.NewTheme.descriptionBackgroundTransparency
		case .lyricsAlignment: return Text.NewTheme.descriptionAlignment
		case .lyricsBorderColor: return Text.NewTheme.borderColor
		case .lyricsBorderSize: return Text.NewTheme.borderSizeDescription
		case .lyricsFontName: return Text.NewTheme.fontFamilyDescription
		case .lyricsTextColorHex: return Text.NewTheme.textColor
		case .lyricsTextSize: return Text.NewTheme.fontSizeDescription
			
		case .titleAlignment: return Text.NewTheme.descriptionAlignment
		case .titleBackgroundColor: return Text.NewTheme.descriptionBackgroundColor
		case .titleBorderColorHex: return Text.NewTheme.borderColor
		case .titleTextSize: return Text.NewTheme.fontSizeDescription
		case .titleFontName: return Text.NewTheme.fontFamilyDescription
		case .titleTextColorHex: return Text.NewTheme.textColor
		case .titleBorderSize: return Text.NewTheme.borderSizeDescription
			
		}
	}
}

extension Theme {
	
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
	
//	@objc override public func delete() {
//		backgroundImage = nil
//		super.delete()
//	}
	
	func getTemp() -> Theme {
		let tempTheme = CoreTheme.createEntity(fireNotification: false)
		tempTheme.isTemp = true
		tempTheme.title = title
		tempTheme.allHaveTitle = allHaveTitle
		tempTheme.hasEmptySheet = hasEmptySheet
		tempTheme.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparency)
		tempTheme.backgroundTransparency = Float(cgfloatValue) * 100
		tempTheme.displayTime = displayTime
		
		tempTheme.titleFontName = titleFontName ?? "Avenir"
		tempTheme.titleTextSize = titleTextSize
		tempTheme.titleBackgroundColor = titleBackgroundColor
		tempTheme.titleAlignmentNumber = titleAlignmentNumber
		tempTheme.titleBorderSize = titleBorderSize
		tempTheme.titleBorderColorHex = titleBorderColorHex
		tempTheme.titleTextColorHex = titleTextColorHex
		tempTheme.isTitleBold = isTitleBold
		tempTheme.isTitleItalian = isTitleItalian
		tempTheme.isTitleUnderlined = isTitleUnderlined
		
		tempTheme.lyricsFontName = lyricsFontName ?? "Avenir"
		tempTheme.lyricsTextSize = lyricsTextSize
		tempTheme.lyricsAlignmentNumber = lyricsAlignmentNumber
		tempTheme.lyricsBorderSize = lyricsBorderSize
		tempTheme.lyricsBorderColorHex = lyricsBorderColorHex
		tempTheme.lyricsTextColorHex = lyricsTextColorHex
		tempTheme.isLyricsBold = isLyricsBold
		tempTheme.isLyricsItalian = isLyricsItalian
		tempTheme.isLyricsUnderlined = isLyricsUnderlined
		tempTheme.isBackgroundImageDeleted = isBackgroundImageDeleted
		
		tempTheme.imagePath = imagePath
		tempTheme.imagePathThumbnail = imagePathThumbnail
		tempTheme.isHidden = isHidden
		return tempTheme
	}
	
	func mergeSelfInto(theme: Theme, isTemp: Bool = false, sheetType: SheetType) {
		if isTemp {
			theme.isDeleted = Date()
		}
		theme.title = title
		theme.allHaveTitle = allHaveTitle
		theme.hasEmptySheet = hasEmptySheet
		theme.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparency)
		theme.backgroundTransparency = Float(cgfloatValue) * 100
		theme.displayTime = displayTime
		
		theme.titleFontName = titleFontName ?? "Avenir"
		theme.titleTextSize = titleTextSize
		if sheetType != .SheetPastors {
			theme.titleBackgroundColor = titleBackgroundColor
			theme.titleAlignmentNumber = titleAlignmentNumber
		}
		theme.titleBorderSize = titleBorderSize
		theme.titleBorderColorHex = titleBorderColorHex
		theme.titleTextColorHex = titleTextColorHex
		theme.isTitleBold = isTitleBold
		theme.isTitleItalian = isTitleItalian
		theme.isTitleUnderlined = isTitleUnderlined
		
		theme.lyricsFontName = lyricsFontName ?? "Avenir"
		theme.lyricsTextSize = lyricsTextSize
		if sheetType != .SheetPastors {
			theme.lyricsAlignmentNumber = lyricsAlignmentNumber
		}
		theme.lyricsBorderSize = lyricsBorderSize
		theme.lyricsBorderColorHex = lyricsBorderColorHex
		theme.lyricsTextColorHex = lyricsTextColorHex
		theme.isLyricsBold = isLyricsBold
		theme.isLyricsItalian = isLyricsItalian
		theme.isLyricsUnderlined = isLyricsUnderlined
		theme.isBackgroundImageDeleted = isBackgroundImageDeleted
		
		theme.imagePath = imagePath
		theme.imagePathThumbnail = imagePathThumbnail
	}

}
