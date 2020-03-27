//
//  ThemeExtensions.swift
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
	case isContentBold
	case isContentItalic
	case isContentUnderlined
	case isTitleBold
	case isTitleItalic
	case isTitleUnderlined
	
	case backgroundColor
	case backgroundImage
	case backgroundTransparancy

	case contentAlignment
	case contentBorderColor
	case contentFontName
	case contentTextColorHex
	case contentTextSize
	case contentBorderSize
	
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
		case .isContentBold: return Text.NewTheme.bold
		case .isContentItalic: return Text.NewTheme.italic
		case .isContentUnderlined: return Text.NewTheme.underlined
		case .isTitleBold: return Text.NewTheme.bold
		case .isTitleItalic: return Text.NewTheme.italic
		case .isTitleUnderlined: return Text.NewTheme.underlined
			
		case .backgroundColor: return Text.NewTheme.descriptionBackgroundColor
		case .backgroundImage: return Text.NewTheme.backgroundImage
		case .backgroundTransparancy: return Text.NewTheme.descriptionBackgroundTransparency
		case .contentAlignment: return Text.NewTheme.descriptionAlignment
		case .contentBorderColor: return Text.NewTheme.borderColor
		case .contentBorderSize: return Text.NewTheme.borderSizeDescription
		case .contentFontName: return Text.NewTheme.fontFamilyDescription
		case .contentTextColorHex: return Text.NewTheme.textColor
		case .contentTextSize: return Text.NewTheme.fontSizeDescription
			
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
			guard let hex = contentTextColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				contentTextColorHex = newColor.toHex
			}
		}
	}
	
	var borderColorLyrics: UIColor? {
		get {
			guard let hex = contentBorderColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				contentBorderColorHex = newColor.toHex
			}
		}
	}
	
	func setBackgroundImage(image: UIImage?) throws {
		let savedImage = try UIImage.set(image: image, imagePath: self.imagePath, thumbnailPath: self.imagePathThumbnail)
		self.imagePath = savedImage.imagePath
		self.imagePathThumbnail = savedImage.thumbPath
	}
	
	private(set) var backgroundImage: UIImage? {
		get {
			UIImage.get(imagePath: self.imagePath)
		}
		set {
		}
	}
	
	private(set) var thumbnail: UIImage? {
		get {
			UIImage.get(imagePath: self.imagePathThumbnail)
		}
		set {
		}
	}
	
	func getTitleAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
		var attributes : [NSAttributedString.Key: Any] = [:]
		if let fontFamily = self.titleFontName {
			var font = UIFont(name: fontFamily, size: (CGFloat(self.titleTextSize) * scaleFactor))
			if self.isTitleBold {
				font = font?.setBoldFnc()
			}
			if self.isTitleItalic {
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
			attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
			attributes[.underlineColor] = attributes[.foregroundColor]
		}
		
		
		
		return attributes
	}
	
	func getLyricsAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
		var attributes : [NSAttributedString.Key: Any] = [:]
		if let fontFamily = self.contentFontName {
			var font = UIFont(name: fontFamily, size: (CGFloat(self.contentTextSize) * scaleFactor))
			if self.isContentBold {
				font = font?.setBoldFnc()
			}
			if self.isContentItalic {
				font = font?.setItalicFnc()
			}
			attributes[.font] = font
		}
		
		let paragraph = NSMutableParagraphStyle()
		
		switch contentAlignmentNumber {
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

		attributes[.strokeWidth] = Int(self.contentBorderSize)
		
		if let textColor = self.textColorLyrics {
			attributes[.foregroundColor] = textColor
		} else {
			attributes[.foregroundColor] = UIColor.black
		}
		
		if let borderColor = self.borderColorLyrics {
			attributes[.strokeColor] = borderColor
		}
		
		if self.isContentUnderlined {
			attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
		}
		return attributes
	}
	
	var backgroundTransparancy: Double {
		get { return backgroundTransparancyNumber }
		set { backgroundTransparancyNumber = newValue / 100 }
	}
	
}

extension Theme {
	
	func setBackgroundImage(image: UIImage?) throws {
		let savedImage = try UIImage.set(image: image, imagePath: self.imagePath, thumbnailPath: self.imagePathThumbnail)
		self.imagePath = savedImage.imagePath
		self.imagePathThumbnail = savedImage.thumbPath
	}
	
	private(set) var backgroundImage: UIImage? {
		get {
			UIImage.get(imagePath: self.imagePath)
		}
		set {
		}
	}
	
	private(set) var thumbnail: UIImage? {
		get {
			UIImage.get(imagePath: self.imagePathThumbnail)
		}
		set {
		}
	}

	
	override public func delete(_ save: Bool = true, isBackground: Bool, completion: ((Error?) -> Void)) {
		do {
			_ = try setBackgroundImage(image: nil)
			completion(nil)
		} catch let error {
			completion(error)
		}
		super.delete(save, isBackground: isBackground, completion: completion)
	}
	

}
