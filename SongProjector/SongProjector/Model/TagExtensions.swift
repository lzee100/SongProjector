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
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
			attributes[.underlineColor] = attributes[.foregroundColor]
		}
		
		
		
		return attributes
	}
	
	func getLyricsAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedStringKey: Any] {
		var attributes : [NSAttributedStringKey: Any] = [:]
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
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
		}
		return attributes
	}
	
	var backgroundTransparancy: Float {
		get { return Float(backgroundTransparancyNumber) }
		set { backgroundTransparancyNumber = newValue / 100 }
	}
	
//	@objc override public func delete() {
//		backgroundImage = nil
//		super.delete()
//	}
	
	func getTemp() -> Theme {
		let tempTheme = CoreTheme.createEntityNOTsave()
		tempTheme.isTemp = true
		tempTheme.title = title
		tempTheme.allHaveTitle = allHaveTitle
		tempTheme.hasEmptySheet = hasEmptySheet
		tempTheme.isEmptySheetFirst = isEmptySheetFirst
		tempTheme.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparancy)
		tempTheme.backgroundTransparancy = Float(cgfloatValue) * 100
		tempTheme.displayTime = displayTime
		
		tempTheme.titleFontName = titleFontName ?? "Avenir"
		tempTheme.titleTextSize = titleTextSize
		tempTheme.titleBackgroundColor = titleBackgroundColor
		tempTheme.titleAlignmentNumber = titleAlignmentNumber
		tempTheme.titleBorderSize = titleBorderSize
		tempTheme.titleBorderColorHex = titleBorderColorHex
		tempTheme.titleTextColorHex = titleTextColorHex
		tempTheme.isTitleBold = isTitleBold
		tempTheme.isTitleItalic = isTitleItalic
		tempTheme.isTitleUnderlined = isTitleUnderlined
		
		tempTheme.contentFontName = contentFontName ?? "Avenir"
		tempTheme.contentTextSize = contentTextSize
		tempTheme.contentAlignmentNumber = contentAlignmentNumber
		tempTheme.contentBorderSize = contentBorderSize
		tempTheme.contentBorderColorHex = contentBorderColorHex
		tempTheme.contentTextColorHex = contentTextColorHex
		tempTheme.isContentBold = isContentBold
		tempTheme.isContentItalic = isContentItalic
		tempTheme.isContentUnderlined = isContentUnderlined
		tempTheme.isBackgroundImageDeleted = isBackgroundImageDeleted
		
		tempTheme.imagePath = imagePath
		tempTheme.imagePathThumbnail = imagePathThumbnail
		tempTheme.isHidden = isHidden
		return tempTheme
	}
	
	func mergeSelfInto(theme: Theme, isTemp: NSDate? = nil, sheetType: SheetType) {
		theme.deleteDate = isTemp
		theme.title = title
		theme.allHaveTitle = allHaveTitle
		theme.hasEmptySheet = hasEmptySheet
		theme.isEmptySheetFirst = isEmptySheetFirst
		theme.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparancy)
		theme.backgroundTransparancy = Float(cgfloatValue) * 100
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
		theme.isTitleItalic = isTitleItalic
		theme.isTitleUnderlined = isTitleUnderlined
		
		theme.contentFontName = contentFontName ?? "Avenir"
		theme.contentTextSize = contentTextSize
		if sheetType != .SheetPastors {
			theme.contentAlignmentNumber = contentAlignmentNumber
		}
		theme.contentBorderSize = contentBorderSize
		theme.contentBorderColorHex = contentBorderColorHex
		theme.contentTextColorHex = contentTextColorHex
		theme.isContentBold = isContentBold
		theme.isContentItalic = isContentItalic
		theme.isContentUnderlined = isContentUnderlined
		theme.isBackgroundImageDeleted = isBackgroundImageDeleted
		
		theme.imagePath = imagePath
		theme.imagePathThumbnail = imagePathThumbnail
		
		if isBackgroundImageDeleted {
			theme.backgroundImage = nil
			theme.isBackgroundImageDeleted = false
		}
		
		print("merged theme")

	}
	
	public override func delete(_ save: Bool) {
		imagePath = nil
		moc.delete(self)
		if save {
			do {
				try moc.save()
			} catch {
				print(error)
			}
		}
	}
	
	public override func deleteBackground(_ save: Bool) {
		imagePath = nil
		mocBackground.delete(self)
		mocBackground.performAndWait {
			do {
				try mocBackground.save()
				try moc.save()
			} catch {
				print(error)
			}
		}
	}

}
